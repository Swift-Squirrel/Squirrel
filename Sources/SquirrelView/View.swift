//
//  View.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

import PathKit
import SquirrelConfig
import Foundation
import SquirrelJSONEncoding
import NutView
import Evaluation
import Regex

public struct View: ViewProtocol {
    public mutating func getContent() throws -> String {
        guard sourceExists else {
            throw ViewError(kind: .notExists, description: "Source file \(name).nut does not exists")
        }
        if compiledExists {
            guard let nutModif = getModificationDate(path: nut) else {
                throw ViewError(kind: .getModif, description: "Can not get modif date for \(name).nut")
            }

            guard let fruitModif = getModificationDate(path: fruit) else {
                throw ViewError(kind: .getModif, description: "Can not get modif date for \(name).fruit")
            }

            if fruitModif > nutModif {
                let json: String = try fruit.read()
                guard let serialized = JSONCoding.toJSON(json: json) else {
                    return "run json error" // TODO
                }
                guard let tkns = serialized as? [String: Any] else {
                    return "json is not dic"
                }
                interpretedTokens = tkns
                return try run()
            }
        }

        try compile()
        
        return try run()
    }

    private let nut: Path
    private let fruit: Path
    private let resources: Path
    private let storage: Path
    private let interpreter: NutInterpreterProtocol
    private var interpretedTokens = [String: Any]()

    private let name: String

    public var sourceExists: Bool {
        return nut.exists
    }

    private var compiledExists: Bool {
        return fruit.exists
    }

    private func getModificationDate(path: Path) -> Date? {
        return (try? FileManager.default.attributesOfItem(atPath: path.string))?[FileAttributeKey.modificationDate] as? Date
    }

    private mutating func compile() throws {
        let cont: String = try nut.read()
        interpreter.setContent(content: cont)
        interpretedTokens = try interpreter.tokenize()
        try fruit.write(interpreter.jsonSerialized)
    }

    private func run() throws -> String {
        var result = ""
        if interpretedTokens["body"] != nil, let body = interpretedTokens["body"]! as? [[String: Any]] {
            result = try runBody(tokens: body, with: data)

        }

        if let head = interpretedTokens["head"] as? [[String: Any]] {
            var headResult = ""
            headResult = try getHead(tokens: head, with: data)
            let headTag = Regex("<head>.*</head>")
            if headTag.matches(result) {
                result.replaceFirst(matching: "</head>", with: headResult + "</head>")
            } else {
                let bodyTag = Regex("<body>.*</body>")
                if bodyTag.matches(result) {
                    result.replaceFirst(matching: "<body>", with: "<head>\n" + headResult + "</head>\n<body>")
                } else {
                    result = "<!DOCTYPE><html><head>\n" + headResult + "</head>\n<body>\n" + result + "\n</body></html>"
                }
            }
        }
        return result
    }

    private func getHead(tokens body: [[String: Any]], with data: [String: Any]) throws -> String {
        var result = ""
        for token in body {
            let id = token["id"]! as! String
            switch id {
            case "title":
                guard let exprToken = token["expression"] as? [String: Any] else {
                    return "no expression in title" // TODO
                }
                let headRes = try parseExpression(token: exprToken, with: data)
                result += "<title>" + headRes + "</title>\n"
            default:
                break
            }
        }
        return result
    }

    private func runBody(tokens body: [[String: Any]], with data: [String: Any]) throws -> String {
        var result = ""
        for token in body {
            let id = token["id"]! as! String
            switch id {
            case "text":
                result += token["value"]! as! String
            case "expression":
                result += try parseExpression(token: token, with: data)
            case "for in Array":
                result += try runForInArray(token: token, with: data)
            default:
                break
            }
        }
        return result
    }

    func parseExpression(token: [String: Any], with data: [String: Any]) throws -> String {
        guard let infixAny = token["infix"] else {
            return ""
        }
        guard let infix = infixAny as? String else {
            return "" // TODO
        }
        if let expRes = try infix.evaluate(with: data) {
            return String(describing: expRes)
        }

        return "nil"
    }


    func runForInArray(token: [String: Any], with data: [String: Any]) throws -> String {
        var result = ""

        let variableName = token["variable"]! as! String

        guard let arr = getValue(name: token["array"]! as! String, from: data) else {
            return "array not found" // TODO
        }

        guard let array = arr as? [Any] else {
            return "not array" // TODO
        }

        var newData = data

        guard token["body"] != nil, let body = token["body"]! as? [[String: Any]] else {
            return "bad body in for" // TODO
        }

        for item in array {
            newData[variableName] = unwrap(any: item)
            result += try runBody(tokens: body, with: newData)
        }

        return result
    }

    private func unwrap(any:Any, ifNil: Any = "nil") -> Any {

        let mi = Mirror(reflecting: any)
        if let dispStyle = mi.displayStyle {
            switch dispStyle {
            case .optional:
                if mi.children.count == 0 { return ifNil }
                let (_, some) = mi.children.first!
                return some
            default:
                return any
            }
        }
        return any
    }

    private func getValue(name: String, from data: [String: Any]) -> Any? {
        if name.contains(".") {
            let separated = name.components(separatedBy: ".")
            if separated.count == 2 {
                if separated[1] == "count" {
                    if let arr = data[separated[0]] as? [Any] {
                        return arr.count
                    } else if let dir = data[separated[0]] as? [String: Any] {
                        return dir.count
                    }
                }
            }
            guard let newData = data[separated[0]] as? [String: Any] else {
                return nil
            }
            var seps = separated
            seps.removeFirst()
            return getValue(name: seps.joined(separator: "."), from: newData)
        } else {
            return (data[name] == nil) ? nil : unwrap(any: data[name]!)
        }
    }

    private var data: [String: Any]

    public init(name: String) {
        self.name = name
        nut = Path(components: [Config.sharedInstance.views.string, name + ".nut"]).normalize()
        resources = nut.parent()
        fruit = Path(components: [Config.sharedInstance.storageViews.string, name + ".fruit"]).normalize()
        storage = fruit.parent()
        interpreter = NutInterpreter(resources: resources, storage: storage)
        self.data = [:]
    }

    public init<T>(name: String, object: T) throws {
        self.init(name: name)
        guard let data = JSONCoding.encodeSerializeJSON(object: object) as? [String: Any] else {
            throw JSONError(kind: .encodeError, message: "Encode error")
        }
        self.data = data
    }
}

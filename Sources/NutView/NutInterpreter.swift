//
//  NutInterpreter.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/11/17.
//
//

import Foundation
import Evaluation
import Regex

public protocol NutInterpreterProtocol {
    init(view name: String, with data: [String : Any])

    func resolve() throws -> String
}

public class NutInterpreter: NutInterpreterProtocol {
    private let name: String
    fileprivate var data: [String: Any]
    private let resolver: NutResolverProtocol

    public required init(view name: String, with data: [String: Any]) {
        self.name = name
        self.data = data
        self.resolver = NutResolver.sharedInstance
    }


    public func resolve() throws -> String {
        let viewToken = try resolver.viewToken(for: "Views." + name)
        do {
            var result = try run(body: viewToken.body)
            if viewToken.head.count > 0 {
                let headResult = try run(head: viewToken.head)

                let headTag = Regex("<head>.*</head>")
                if headTag.matches(result) {
                    result.replaceFirst(matching: "</head>", with: headResult + "</head>")
                } else {
                    let bodyTag = Regex("<body>.*</body>")
                    if bodyTag.matches(result) {
                        result.replaceFirst(matching: "<body>", with: "<head>\n" + headResult + "</head>\n<body>")
                    } else {
                        result = "<!DOCTYPE><html><head>\n" + headResult + "</head>\n<body>\n" + result + "\n</body>\n</html>"
                    }
                }

            }

            return result
        } catch var error as NutParserError {
            guard error.name == nil else {
                throw error
            }
            error.name = viewToken.name
            throw error
        }
    }

    fileprivate func run(head: [NutHeadProtocol]) throws -> String {
        var res = ""
        for token in head {
            switch token {
            case let title as TitleToken:
                res += try parse(title: title)
            default:
                res += "UnknownToken<" + token.id + ">"
            }
        }
        return res
    }

    fileprivate func run(body: [NutTokenProtocol]) throws -> String {
        var res = ""
        for token in body {
            switch token {
            case let expression as ExpressionToken:
                res += try parse(expression: expression)
            case let forIn as ForInToken:
                res += try parse(forIn: forIn)
            case let text as TextToken:
                res += text.value
            default:
                res += "UnknownToken<" + token.id + ">"
            }
        }
        return res
    }
}

// Head parsing
extension NutInterpreter {
    fileprivate func parse(title: TitleToken) throws -> String {
        let expr = try parse(expression: title.expression)
        return "<title>\(expr)</title>"
    }
}

// getValue
extension NutInterpreter {
    fileprivate func unwrap(any: Any, ifNil: Any = "nil") -> Any {

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

    fileprivate func getValue(name: String, from data: [String: Any]) -> Any? {
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

}

// Body parsing
extension NutInterpreter {
    fileprivate func parse(expression: ExpressionToken) throws -> String {
        do {
            let res = try expression.infix.evaluate(with: data)
            return String(describing: unwrap(any: res ?? "nil"))
        } catch let error as EvaluationError {
            throw NutParserError(kind: .evaluationError(infix: expression.infix, message: error.description), row: expression.row)
        }
    }

    fileprivate func parse(forIn: ForInToken) throws -> String {
        let prevValue = data[forIn.variable]
        var res = ""
        guard let arr = getValue(name: forIn.array, from: data) else {
            throw NutParserError(kind: .missingValue(for: forIn.array), row: forIn.row)

        }
        if let keyName = forIn.key {
            let prevKey = data[keyName]
            guard let dic = arr as? [String: Any] else {
                throw NutParserError(kind: .wrongValue(for: forIn.array, expected: "[String: Any]", got: arr), row: forIn.row)
            }
            for (key, value) in dic {
                data[forIn.variable] = value
                data[keyName] = key
                res += try run(body: forIn.body)
            }
            data[keyName] = prevKey
        } else {
            guard let array = arr as? [Any] else {
                throw NutParserError(kind: .wrongValue(for: forIn.array, expected: "[Any]", got: arr), row: forIn.row)
            }
            for item in array {
                data[forIn.variable] = unwrap(any: item)
                res += try run(body: forIn.body)
            }
        }
        data[forIn.variable] = prevValue
        return res
    }
}

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

protocol NutInterpreterProtocol {
    init(view name: String, with data: [String : Any])

    func resolve() throws -> String
}

class NutInterpreter: NutInterpreterProtocol {
    private let name: String
    private var data: [String: Any]
    private let resolver: NutResolverProtocol.Type = NutResolver.self
    private let viewName: String

    required init(view name: String, with data: [String: Any]) {
        self.name = name
        self.data = data
        viewName = "Views." + name
    }


    func resolve() throws -> String {
        let viewToken = try resolver.viewToken(for: viewName)
        do {
            var result: String
            var heads: [NutHeadProtocol]
            if let layoutToken = viewToken.layout {
                let layout = try resolver.viewToken(for: layoutToken.name)
                let res = try run(body: layout.body)
                result = res.result
                heads = layout.head + res.heads
            } else {
                let res = try run(body: viewToken.body)
                result = res.result
                heads = viewToken.head + res.heads
            }
            if heads.count > 0 {
                let headResult = try run(head: heads)

                let headTag = Regex("[\\s\\S]*<head>[\\s\\S]*</head>[\\s\\S]*")
                if headTag.matches(result) {
                    result.replaceFirst(matching: "</head>", with: headResult + "\n</head>")
                } else {
                    let bodyTag = Regex("[\\s\\S]*<body>[\\s\\S]*</body>[\\s\\S]*")
                    if bodyTag.matches(result) {
                        result.replaceFirst(
                            matching: "<body>",
                            with: "<head>\n" + headResult + "\n</head>\n<body>")
                    } else {
                        result = "<!DOCTYPE>\n<html>\n<head>\n" + headResult
                            + "\n</head>\n<body>\n" + result + "\n</body>\n</html>"
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
                res += convertToSpecialCharacters(string: "UnknownToken<" + token.id + ">\n")
            }
        }
        return res
    }

    fileprivate func run(body: [NutTokenProtocol])
        throws -> (result: String, heads: [NutHeadProtocol]) {

        var res = ""
        var heads = [NutHeadProtocol]()
        for token in body {
            switch token {
            case let expression as ExpressionToken:
                res += try parse(expression: expression)
            case let expression as RawExpressionToken:
                res += try parse(rawExpression: expression)
            case let forIn as ForInToken:
                let res1 = try parse(forIn: forIn)
                heads += res1.heads
                res += res1.result
            case let ifToken as IfToken:
                let res1 = try parse(if: ifToken)
                heads += res1.heads
                res += res1.result
            case let text as TextToken:
                res += text.value
            case let date as DateToken:
                res += try parse(date: date)
            case is InsertViewToken:
                let viewToken = try resolver.viewToken(for: viewName)
                let res1 = try run(body: viewToken.body)
                heads += viewToken.head + res1.heads
                res += res1.result
            case let subviewToken as SubviewToken:
                let subview = try resolver.viewToken(for: subviewToken.name)
                let res1 = try run(body: subview.body)
                heads += subview.head + res1.heads
                res += res1.result
            default:
                res += convertToSpecialCharacters(string: "UnknownToken<" + token.id + ">\n")
            }
        }
        return (res, heads)
    }
}


// HTML escapes
extension NutInterpreter {
    fileprivate func convertToSpecialCharacters(string: String) -> String {
        var newString = string
        let char_dictionary = [
            ("&amp;", "&"),
            ("&lt;", "<"),
            ("&gt;", ">"),
            ("&quot;", "\""),
            ("&apos;", "'")
        ]
        for (escaped_char, unescaped_char) in char_dictionary {
            newString = newString.replacingOccurrences(
                of: unescaped_char,
                with: escaped_char,
                options: NSString.CompareOptions.literal,
                range: nil)
        }
        return newString
    }
}

// Head parsing
extension NutInterpreter {
    fileprivate func parse(title: TitleToken) throws -> String {
        let expr = try parse(rawExpression: title.expression)
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
    private func parse(rawExpression expression: RawExpressionToken) throws -> String {
        do {
            let res = try expression.evaluate(with: data)
            let str = String(describing: unwrap(any: res ?? "nil"))
            return str
        } catch let error as EvaluationError {
            throw NutParserError(
                kind: .evaluationError(infix: expression.infix, message: error.description),
                line: expression.line)
        }
    }

    fileprivate func parse(expression: ExpressionToken) throws -> String {
        do {
            let res = try expression.evaluate(with: data)
            let str = String(describing: unwrap(any: res ?? "nil"))
            return convertToSpecialCharacters(string: str)
        } catch let error as EvaluationError {
            throw NutParserError(
                kind: .evaluationError(infix: expression.infix, message: error.description),
                line: expression.line)
        }
    }

    private func parse(date dateToken: DateToken) throws -> String {
        let dateStr = try parse(rawExpression: dateToken.date)
        guard let dateMiliseconds = Double(dateStr) else {
            throw NutParserError(
                kind: .wrongValue(for: "Date(_:format:)", expected: "Double", got: dateStr),
                line: dateToken.date.line)
        }
        let format: RawExpressionToken
        if dateToken.format == nil {
            format = RawExpressionToken(
                infix: "\"\(NutConfig.dateDefaultFormat)\"",
                line: dateToken.line)
        } else {
            format = dateToken.format!
        }
        let formatStr = try parse(rawExpression: format)
        let date = Date(timeIntervalSince1970: dateMiliseconds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatStr
        return dateFormatter.string(from: date)
    }

    fileprivate func parse(forIn: ForInToken) throws -> (result: String, heads: [NutHeadProtocol]) {
        guard let arr = getValue(name: forIn.array, from: data) else {
            throw NutParserError(kind: .missingValue(for: forIn.array), line: forIn.line)

        }
        let prevValue = data[forIn.variable]
        var res = ""
        var heads = [NutHeadProtocol]()
        if let keyName = forIn.key {
            let prevKey = data[keyName]
            guard let dic = arr as? [String: Any] else {
                throw NutParserError(
                    kind: .wrongValue(for: forIn.array, expected: "[String: Any]", got: arr),
                    line: forIn.line)
            }
            for (key, value) in dic {
                data[forIn.variable] = value
                data[keyName] = key
                let result = try run(body: forIn.body)
                res += result.result
                heads += result.heads
            }
            data[keyName] = prevKey
        } else {
            guard let array = arr as? [Any] else {
                throw NutParserError(
                    kind: .wrongValue(for: forIn.array, expected: "[Any]", got: arr),
                    line: forIn.line)
            }
            for item in array {
                data[forIn.variable] = unwrap(any: item)
                let result = try run(body: forIn.body)
                res += result.result
                heads += result.heads
            }
        }
        data[forIn.variable] = prevValue
        return (res, heads)
    }

    fileprivate func parse(if ifToken: IfToken)
        throws -> (result: String, heads: [NutHeadProtocol]) {

        let any: Any?
        do {
            any = try ifToken.condition.evaluate(with: data)
        } catch let error as EvaluationError {
            throw NutParserError(
                kind: .evaluationError(infix: ifToken.condition.infix, message: error.description),
                line: ifToken.line)
        }
        if let variable = ifToken.variable {
            if let value = any {
                let prevValue = data[variable]
                data[variable] = value
                let res = try run(body: ifToken.thenBlock)
                data[variable] = prevValue
                return res
            } else if let elseBlock = ifToken.elseBlock {
                return try run(body: elseBlock)
            }
        } else {
            if let condition = any as? Bool {
                if condition {
                    return try run(body: ifToken.thenBlock)
                } else if let elseBlock = ifToken.elseBlock {
                    return try run(body: elseBlock)
                }
            } else {
                throw NutParserError(
                    kind: .wrongValue(
                        for: ifToken.id,
                        expected: "<expression: Bool>",
                        got: String(describing: any ?? "nil")),
                    line: ifToken.line)
            }
        }
        return ("", [])
    }
}

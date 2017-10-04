//
//  NutToken.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/7/17.
//
//

// swiftlint:disable file_length

import Foundation
import Evaluation

protocol NutTokenProtocol {
    var id: String { get }

    var serialized: [String: Any] { get }
}

protocol NutCommandTokenProtocol: NutTokenProtocol {
    var line: Int { get }
}

protocol NutViewProtocol: NutCommandTokenProtocol {
    var name: String { get }
}

protocol NutSubviewProtocol: NutViewProtocol {

}

protocol NutLayoutProtocol: NutViewProtocol {

}

protocol NutHeadProtocol: NutCommandTokenProtocol {

}

protocol IfTokenProtocol: NutCommandTokenProtocol {
    init(condition: String, line: Int) throws
    mutating func setThen(body: [NutTokenProtocol])
    mutating func setElse(body: [NutTokenProtocol])
    var variable: String? { get }
    var condition: RawExpressionToken { get }
}

struct TextToken: NutTokenProtocol {
    let id = "text"

    let value: String

    init(value: String) {
        self.value = value
    }

    var serialized: [String: Any] {
        return ["id": id, "value": value]
    }
}

struct InsertViewToken: NutCommandTokenProtocol {
    var line: Int

    let id = "view"

    init(line: Int) {
        self.line = line
    }

    var serialized: [String: Any] {
        return ["id": id, "line": line]
    }
}

struct DateToken: NutCommandTokenProtocol {
    let line: Int

    let id = "date"

    let date: RawExpressionToken

    let format: RawExpressionToken?

    init(date: RawExpressionToken, format: RawExpressionToken? = nil, line: Int) {
        self.date = date
        self.line = line
        self.format = format
    }

    var serialized: [String : Any] {
        var res: [String: Any] = [
            "id": id,
            "date": date.serialized,
            "line": line
        ]
        if let format = self.format {
            res["format"] = format.serialized
        }
        return res
    }
}

struct IfToken: NutCommandTokenProtocol, IfTokenProtocol {
    private let _id: IDNames

    var id: String {
        return _id.rawValue
    }

    enum IDNames: String {
        case `if`
        case `ifLet` = "if let"
    }

    let line: Int

    let condition: RawExpressionToken

    var thenBlock = [NutTokenProtocol]()

    var elseBlock: [NutTokenProtocol]? = nil

    mutating func setThen(body: [NutTokenProtocol]) {
        self.thenBlock = body
    }

    mutating func setElse(body: [NutTokenProtocol]) {
        self.elseBlock = body
    }

    let variable: String?

    init(condition: String, line: Int) throws {
        let expected = [
            "if <expression: Bool> {",
            "if let <variableName: Any> = <expression: Any?> {"
        ]
        let exprCondition: String
        let variable: String?
        if condition.hasPrefix("let ") {
            var separated = condition.components(separatedBy: " ")
            guard separated.count == 4 else {
                throw NutParserError(
                    kind: .syntaxError(expected: expected, got: "if " + condition + " {"),
                    line: line)
            }
            guard separated[2] == "=" else {
                throw NutParserError(
                    kind: .syntaxError(expected: expected, got: "if " + condition + " {"),
                    line: line)
            }
            variable = separated[1]
            separated.removeFirst(3)
            exprCondition = separated.joined(separator: " ")

        } else {
            exprCondition = condition
            variable = nil

        }
        let expr = RawExpressionToken(infix: exprCondition, line: line)

        self.init(variable: variable, condition: expr, line: line)
        try checkVariable()
    }

    init(variable: String? = nil, condition: RawExpressionToken, line: Int) {
        if let variable = variable {
            self._id = IDNames.ifLet
            self.variable = variable
        } else {
            self._id = IDNames.if
            self.variable = nil
        }
        self.line = line
        self.condition = condition
    }

    func checkVariable() throws {
        if let variable = variable {
            guard VariableCheck.checkSimple(variable: variable) else {
                throw NutParserError(
                    kind: .wrongSimpleVariable(
                        name: variable,
                        in: "if let \(variable) = \(condition.infix) {",
                        regex: VariableCheck.simpleVariable.regex),
                    line: line)
            }
            guard VariableCheck.checkChained(variable: condition.infix) else {
                throw NutParserError(
                    kind: .wrongChainedVariable(
                        name: condition.infix,
                        in: "if let \(variable) = \(condition.infix) {",
                        regex: VariableCheck.chainedVariable.regex),
                    line: line)
            }
        }
    }

    var serialized: [String: Any] {
        var res: [String: Any] = [
            "id": id,
            "condition": condition.serialized,
            "then": thenBlock.map({ $0.serialized }),
            "line": line
        ]
        if let variable = self.variable {
            res["variable"] = variable
        }
        if let elseBlock = self.elseBlock {
            res["else"] = elseBlock.map({ $0.serialized })
        }
        return res
    }
}

struct ElseIfToken: NutCommandTokenProtocol, IfTokenProtocol {
    enum IDNames: String {
        case elseIf = "else if"
        case elseIfLet = "else if let"
    }

    private let _id: IDNames

    var id: String {
        return _id.rawValue
    }

    let line: Int

    let condition: RawExpressionToken

    private var thenBlock = [NutTokenProtocol]()

    private var elseBlock: [NutTokenProtocol]? = nil

    func getElse() -> [NutTokenProtocol]? {
        return elseBlock
    }

    func getThen() -> [NutTokenProtocol] {
        return thenBlock
    }

    func getCondition() -> RawExpressionToken {
        return condition
    }

    mutating func setThen(body: [NutTokenProtocol]) {
        self.thenBlock = body
    }

    mutating func setElse(body: [NutTokenProtocol]) {
        self.elseBlock = body
    }

    let variable: String?

    private let expected = [
        "} else if <expression: Bool> {",
        "} else if let <variableName: Any> = <expression: Any?> {"
    ]

    init(condition: String, line: Int) throws {
        let exprCon: String
        if condition.hasPrefix("let ") {
            var separated = condition.components(separatedBy: " ")
            guard separated.count == 4 else {
                throw NutParserError(
                    kind: .syntaxError(
                        expected: expected,
                        got: "} else if \(condition) {"),
                    line: line)
            }
            guard separated[2] == "=" else {
                throw NutParserError(
                    kind: .syntaxError(
                        expected: expected,
                        got: "} else if \(condition) {"),
                    line: line)
            }
            variable = separated[1]
            separated.removeFirst(3)
            exprCon = separated.joined(separator: " ")
            _id = IDNames.elseIfLet
        } else {
            exprCon = condition
            variable = nil
            _id = IDNames.elseIf
        }
        let expr = RawExpressionToken(infix: exprCon, line: line)
        self.condition = expr
        self.line = line
        try checkVariable()
    }

    func checkVariable() throws {
        if let variable = variable {
            guard VariableCheck.checkSimple(variable: variable) else {
                throw NutParserError(
                    kind: .wrongSimpleVariable(
                        name: variable,
                        in: "} else if let \(variable) = \(condition.infix) {",
                        regex: VariableCheck.simpleVariable.regex),
                    line: line)
            }
            guard VariableCheck.checkChained(variable: condition.infix) else {
                throw NutParserError(
                    kind: .wrongChainedVariable(
                        name: condition.infix,
                        in: "} else if let \(variable) = \(condition.infix) {",
                        regex: VariableCheck.chainedVariable.regex),
                    line: line)
            }
        }
    }

    var serialized: [String: Any] {
        var res: [String: Any] = [
            "id": id,
            "condition": condition.serialized,
            "then": thenBlock.map({ $0.serialized }),
            "line": line
        ]
        if let variable = self.variable {
            res["variable"] = variable
        }
        if let elseBlock = self.elseBlock {
            res["else"] = elseBlock.map({ $0.serialized })
        }
        return res
    }
}

struct LayoutToken: NutLayoutProtocol {
    let id = "layout"

    let line: Int

    let name: String

    init(name: String, line: Int) {
        self.line = line
        self.name = name
    }

    var serialized: [String: Any] {
        return ["id": id, "name": name, "line": line]
    }
}

struct SubviewToken: NutSubviewProtocol {
    var name: String

    var line: Int

    let id = "subview"

    init(name: String, line: Int) {
        self.line = line
        self.name = name
    }

    var serialized: [String : Any] {
        return ["id": id, "line": line, "name": name]
    }
}

struct TitleToken: NutHeadProtocol {
    let id = "title"

    let line: Int

    let expression: RawExpressionToken

    init(expression: RawExpressionToken, line: Int) {
        self.line = line
        self.expression = expression
    }

    var serialized: [String: Any] {
        return ["id": id, "expression": expression.serialized, "line": line]
    }
}

struct ForInToken: NutCommandTokenProtocol {
    enum IDNames: String {
        case forInArray = "for in Array"
        case forInDictionary = "for in Dictionary"
    }

    private let _id: IDNames
    var id: String {
        return _id.rawValue
    }

    let line: Int

    let variable: String

    let key: String?

    let array: String

    var body: [NutTokenProtocol]

    mutating func setBody(body: [NutTokenProtocol]) {
        self.body = body
    }

    init(key: String? = nil, variable: String, array: String, line: Int) {
        self.line = line
        if key == nil {
            _id = IDNames.forInArray
        } else {
            _id = IDNames.forInDictionary
        }
        self.key = key
        self.variable = variable
        self.array = array
        self.body = []
    }

    var serialized: [String: Any] {
        var res: [String: Any] = [
            "id": id,
            "variable": variable,
            "array": array,
            "body": body.map({ $0.serialized }),
            "line": line
        ]
        if let key = self.key {
            res["key"] = key
        }
        return res
    }
}

struct ElseToken: NutCommandTokenProtocol {
    let id = "else"

    let line: Int

    private var body = [NutTokenProtocol]()

    init(line: Int) {
        self.line = line
    }

    func getBody() -> [NutTokenProtocol] {
        return body
    }

    mutating func setBody(body: [NutTokenProtocol]) {
        self.body = body
    }

    var serialized: [String: Any] {
        return ["id": id, "line": line]
    }
}

struct EndBlockToken: NutCommandTokenProtocol {
    let id = "}"

    let line: Int

    var serialized: [String: Any] {
        return ["id": id, "line": line]
    }
}

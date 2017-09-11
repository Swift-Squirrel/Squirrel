//
//  NutToken.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/7/17.
//
//

import Foundation

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

protocol IfTokenProtocol: NutCommandTokenProtocol {
    init?(condition: String, line: Int)
    mutating func setThen(body: [NutTokenProtocol])
    mutating func setElse(body: [NutTokenProtocol])
}

struct DateToken: NutCommandTokenProtocol {
    let line: Int

    let id = "date"

    let date: ExpressionToken

    let format: ExpressionToken?

    init(date: ExpressionToken, format: ExpressionToken? = nil, line: Int) {
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
    let id: String

    let line: Int

    let condition: String

    var thenBlock = [NutTokenProtocol]()

    var elseBlock: [NutTokenProtocol]? = nil

    mutating func setThen(body: [NutTokenProtocol]) {
        self.thenBlock = body
    }

    mutating func setElse(body: [NutTokenProtocol]) {
        self.elseBlock = body
    }

    let variable: String?

    init(variable: String, condition: String, line: Int) {
        self.line = line
        self.id = "if let"
        self.variable = variable
        self.condition = condition
    }

    init?(condition: String, line: Int) {
        self.line = line
        if condition.hasPrefix("let ") {
            var separated = condition.components(separatedBy: " ")
            guard separated.count == 4 else {
                return nil
            }
            guard separated[2] == "=" else {
                return nil
            }
            variable = separated[1]
            separated.removeFirst(3)
            self.condition = separated.joined(separator: " ")
            id = "if let"
        } else {
            self.condition = condition
            variable = nil
            id = "if"
        }
    }

    var serialized: [String: Any] {
        var res: [String: Any] = [
            "id": id,
            "condition": condition,
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
    let id: String

    let line: Int

    let condition: String

    private var thenBlock = [NutTokenProtocol]()

    private var elseBlock: [NutTokenProtocol]? = nil

    func getElse() -> [NutTokenProtocol]? {
        return elseBlock
    }

    func getThen() -> [NutTokenProtocol] {
        return thenBlock
    }

    func getCondition() -> String {
        return condition
    }

    mutating func setThen(body: [NutTokenProtocol]) {
        self.thenBlock = body
    }

    mutating func setElse(body: [NutTokenProtocol]) {
        self.elseBlock = body
    }

    let variable: String?

    init?(condition: String, line: Int) {
        self.line = line
        if condition.hasPrefix("let ") {
            var separated = condition.components(separatedBy: " ")
            guard separated.count == 4 else {
                return nil
            }
            guard separated[2] == "=" else {
                return nil
            }
            variable = separated[1]
            separated.removeFirst(3)
            self.condition = separated.joined(separator: " ")
            id = "else if let"
        } else {
            self.condition = condition
            variable = nil
            id = "else if"
        }
    }

    var serialized: [String: Any] {
        var res: [String: Any] = [
            "id": id,
            "condition": condition,
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

    let expression: ExpressionToken

    init(expression: ExpressionToken, line: Int) {
        self.line = line
        self.expression = expression
    }

    var serialized: [String: Any] {
        return ["id": id, "expression": expression.serialized, "line": line]
    }
}

struct ForInToken: NutCommandTokenProtocol {
    let id: String

    let line: Int

    let variable: String

    let key: String?

    let array: String

    var body = [NutTokenProtocol]()

    mutating func setBody(body: [NutTokenProtocol]) {
        self.body = body
    }

    init(key: String? = nil, variable: String, array: String, line: Int) {
        self.line = line
        if key == nil {
            id = "for in Array"
        } else {
            id = "for in Dictionary"
        }
        self.key = key
        self.variable = variable
        self.array = array
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
        return ["id": "else", "line": line]
    }
}

struct EndBlockToken: NutCommandTokenProtocol {
    let id = "}"

    let line: Int

    var serialized: [String: Any] {
        return ["id": id, "line": line]
    }
}

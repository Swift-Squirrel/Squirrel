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
    var row: Int { get }
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
    var row: Int

    let id = "view"

    init(row: Int) {
        self.row = row
    }

    var serialized: [String: Any] {
        return ["id": id, "row": row]
    }
}

protocol IfTokenProtocol: NutCommandTokenProtocol {
    init(condition: String, row: Int)
    mutating func setThen(body: [NutTokenProtocol])
    mutating func setElse(body: [NutTokenProtocol])
}

struct DateToken: NutCommandTokenProtocol {
    let row: Int

    let id = "date"

    let date: ExpressionToken

    let format: ExpressionToken

    init(date: ExpressionToken, format: ExpressionToken? = nil, row: Int) {
        self.date = date
        self.row = row

        if let format = format {
            self.format = format
        } else {
            self.format = ExpressionToken(infix: "\"MMM dd yyyy\"", row: row)!
        }
    }

    var serialized: [String : Any] {
        return ["id": id, "date": date.serialized, "format": format.serialized]
    }


}

struct IfToken: NutCommandTokenProtocol, IfTokenProtocol {
    let id: String

    let row: Int

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

    init(variable: String, condition: String, row: Int) {
        self.row = row
        self.id = "if let"
        self.variable = variable
        self.condition = condition
    }

    init(condition: String, row: Int) {
        self.row = row
        if condition.hasPrefix("let ") {
            var separated = condition.components(separatedBy: " ")
            //        guard separated.count == 4 else {
            //            return [] // TODO
            //        }
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
        var res: [String: Any] = ["id": id, "condition": condition, "then": thenBlock.map( { $0.serialized }), "row": row]
        if let variable = self.variable {
            res["variable"] = variable
        }
        if let elseBlock = self.elseBlock {
            res["else"] = elseBlock.map( { $0.serialized })
        }
        return res
    }
}

struct ElseIfToken: NutCommandTokenProtocol, IfTokenProtocol {
    let id: String

    let row: Int

    private let condition: String

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

    init(condition: String, row: Int) {
        self.row = row
        if condition.hasPrefix("let ") {
            var separated = condition.components(separatedBy: " ")
            //        guard separated.count == 4 else {
            //            return [] // TODO
            //        }
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
        var res: [String: Any] = ["id": id, "condition": condition, "then": thenBlock.map( { $0.serialized }), "row": row]
        if let variable = self.variable {
            res["variable"] = variable
        }
        if let elseBlock = self.elseBlock {
            res["else"] = elseBlock.map( { $0.serialized })
        }
        return res
    }
}

struct LayoutToken: NutLayoutProtocol {
    let id = "layout"

    let row: Int

    let name: String

    init(name: String, row: Int) {
        self.row = row
        self.name = name
    }

    var serialized: [String: Any] {
        return ["id": id, "name": name, "row": row]
    }
}

struct SubviewToken: NutSubviewProtocol {
    var name: String

    var row: Int

    let id = "subview"

    init(name: String, row: Int) {
        self.row = row
        self.name = name
    }

    var serialized: [String : Any] {
        return ["id": id, "row": row, "name": name]
    }
}

struct TitleToken: NutHeadProtocol {
    let id = "title"

    let row: Int

    let expression: ExpressionToken

    init(expression: ExpressionToken, row: Int) {
        self.row = row
        self.expression = expression
    }

    var serialized: [String: Any] {
        return ["id": id, "expression": expression.serialized, "row": row]
    }
}

struct ForInToken: NutCommandTokenProtocol {
    let id: String

    let row: Int

    let variable: String

    let key: String?

    let array: String

    var body = [NutTokenProtocol]()

    mutating func setBody(body: [NutTokenProtocol]) {
        self.body = body
    }

    init(key: String? = nil, variable: String, array: String, row: Int) {
        self.row = row
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
        var res: [String: Any] = ["id": id, "variable": variable, "array": array, "body": body.map({ $0.serialized }), "row": row]
        if let key = self.key {
            res["key"] = key
        }
        return res
    }
}

struct ElseToken: NutCommandTokenProtocol {
    let id = "else"

    let row: Int

    private var body = [NutTokenProtocol]()

    init(row: Int) {
        self.row = row
    }

    func getBody() -> [NutTokenProtocol] {
        return body
    }

    mutating func setBody(body: [NutTokenProtocol]) {
        self.body = body
    }

    var serialized: [String: Any] {
        return ["id": "else"]
    }
}

struct EndBlockToken: NutCommandTokenProtocol {
    let id = "}"

    let row: Int

    var serialized: [String: Any] {
        return ["id": id]
    }
}

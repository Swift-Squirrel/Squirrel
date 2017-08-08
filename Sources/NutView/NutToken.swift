//
//  NutToken.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/7/17.
//
//

protocol NutTokenProtocol {
    var id: String { get }

    var serialized: Any { get }

}

struct TextToken: NutTokenProtocol {
    let id = "text"

    private let value: String

    init(value: String) {
        self.value = value
    }

    var serialized: Any {
        return ["id": id, "value": value]
    }
}

struct ExpressionToken: NutTokenProtocol {
    let id = "expression"

    private let infix: String

    init(infix: String) {
        self.infix = infix
    }

    var serialized: Any {
        return ["id": id, "infix": infix]
    }
}

protocol IfTokenProtocol: NutTokenProtocol {
    init(condition: String)
    mutating func setThen(body: [NutTokenProtocol])
    mutating func setElse(body: [NutTokenProtocol])
}

struct IfToken: NutTokenProtocol, IfTokenProtocol {
    let id: String

    private let condition: String

    private var thenBlock = [NutTokenProtocol]()

    private var elseBlock: [NutTokenProtocol]? = nil

    mutating func setThen(body: [NutTokenProtocol]) {
        self.thenBlock = body
    }

    mutating func setElse(body: [NutTokenProtocol]) {
        self.elseBlock = body
    }

    private let variable: String?

    init(condition: String) {
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

    var serialized: Any {
        var res: [String: Any] = ["id": id, "condition": condition, "then": thenBlock.map( { $0.serialized })]
        if let variable = self.variable {
            res["variable"] = variable
        }
        if let elseBlock = self.elseBlock {
            res["else"] = elseBlock.map( { $0.serialized })
        }
        return res
    }
}

struct ElseIfToken: NutTokenProtocol, IfTokenProtocol {
    let id: String

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

    private let variable: String?

    init(condition: String) {
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

    var serialized: Any {
        var res: [String: Any] = ["id": id, "condition": condition, "then": thenBlock.map( { $0.serialized })]
        if let variable = self.variable {
            res["variable"] = variable
        }
        if let elseBlock = self.elseBlock {
            res["else"] = elseBlock.map( { $0.serialized })
        }
        return res
    }
}

struct ElseToken: NutTokenProtocol {
    let id = "else"

    private var body = [NutTokenProtocol]()

    func getBody() -> [NutTokenProtocol] {
        return body
    }

    mutating func setBody(body: [NutTokenProtocol]) {
        self.body = body
    }

    var serialized: Any {
        return ["id": "else"]
    }
}

struct EndBlockToken: NutTokenProtocol {
    let id = "}"

    var serialized: Any {
        return ["id": id]
    }
}

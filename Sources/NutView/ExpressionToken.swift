//
//  ExpressionToken.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/9/17.
//
//

import Evaluation

struct ExpressionToken: NutCommandTokenProtocol {
    let id = "expression"

    let line: Int

    let infix: String
    let postfix: String

    init?(infix: String, line: Int) {
        guard let eval = try? InfixEvaluation(expression: infix) else {
            return nil
        }
        guard let postfix: String = try? eval.serializedPostfix() else {
            return nil
        }
        self.postfix = postfix
        self.line = line
        self.infix = infix
    }

    init(infix: String, postfix: String, line: Int) {
        self.infix = infix
        self.postfix = postfix
        self.line = line
    }

    func evaluate(with data: [String: Any]) throws -> Any? {
        let eval = try PostfixEvaluation(postfix: postfix)
        return try eval.evaluate(with: data)
    }

    var serialized: [String: Any] {
        return ["id": id, "postfix": postfix, "infix": infix, "line": line]
    }
}

struct RawExpressionToken: NutCommandTokenProtocol {
    let id = "raw expression"

    let line: Int

    let infix: String
    let postfix: String

    init(infix: String, line: Int) throws {
        let eval = try InfixEvaluation(expression: infix)
        let postfix: String = try eval.serializedPostfix()

        self.postfix = postfix
        self.infix = infix
        self.line = line
    }

    init(infix: String, postfix: String, line: Int) {
        self.infix = infix
        self.postfix = postfix
        self.line = line
    }

    func evaluate(with data: [String: Any]) throws -> Any? {
        let eval = try PostfixEvaluation(postfix: postfix)
        return try eval.evaluate(with: data)
    }

    var serialized: [String: Any] {
        return ["id": id, "postfix": postfix, "infix": infix, "line": line]
    }
}

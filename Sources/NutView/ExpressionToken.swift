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

    init?(infix: String, line: Int) {
        self.infix = infix
        self.line = line
//        let eval = try! Evaluation(expression: infix)
    }

    var serialized: [String: Any] {
        return ["id": id, "infix": infix, "line": line]
    }
}

struct RawExpressionToken: NutCommandTokenProtocol {
    let id = "raw expression"

    let line: Int

    let infix: String

    init?(infix: String, line: Int) {
        self.infix = infix
        self.line = line
        //        let eval = try! Evaluation(expression: infix)

    }

    var serialized: [String: Any] {
        return ["id": id, "infix": infix, "line": line]
    }
}

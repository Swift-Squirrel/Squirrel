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

    let row: Int

    let infix: String

    init?(infix: String, row: Int) {
        self.infix = infix
        self.row = row
//        let eval = try! Evaluation(expression: infix)
        
    }

    var serialized: [String: Any] {
        return ["id": id, "infix": infix]
    }
}

struct RawExpressionToken: NutCommandTokenProtocol {
    let id = "raw expression"

    let row: Int

    let infix: String

    init?(infix: String, row: Int) {
        self.infix = infix
        self.row = row
        //        let eval = try! Evaluation(expression: infix)

    }

    var serialized: [String: Any] {
        return ["id": id, "infix": infix]
    }
}


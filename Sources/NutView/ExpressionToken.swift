//
//  ExpressionToken.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/9/17.
//
//

import Evaluation

struct ExpressionToken: NutTokenProtocol {
    let id = "expression"

    let infix: String

    init?(infix: String) {
        self.infix = infix
//        let eval = try! Evaluation(expression: infix)
        
    }

    var serialized: [String: Any] {
        return ["id": id, "infix": infix]
    }
}

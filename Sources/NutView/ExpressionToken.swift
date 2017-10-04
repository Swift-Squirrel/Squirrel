//
//  ExpressionToken.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/9/17.
//
//

import Evaluation
import SquirrelJSONEncoding
import Foundation

protocol ExpressionTokenProtocol: NutCommandTokenProtocol {
    var infix: String { get }
}

extension ExpressionTokenProtocol {
    func evaluate(with data: [String: Any]) throws -> Any? {
        return try infix.evaluate(with: data)
    }
}

struct ExpressionToken: ExpressionTokenProtocol {
    let id = "expression"

    let line: Int

    let infix: String

    init(infix: String, line: Int) {
        self.line = line
        self.infix = infix
    }

    var serialized: [String: Any] {
        return ["id": id, "infix": infix, "line": line]
    }
}

struct RawExpressionToken: ExpressionTokenProtocol {
    let id = "raw expression"

    let line: Int

    let infix: String

    init(infix: String, line: Int) {
        self.infix = infix
        self.line = line
    }

    var serialized: [String: Any] {
        return ["id": id, "infix": infix, "line": line]
    }
}

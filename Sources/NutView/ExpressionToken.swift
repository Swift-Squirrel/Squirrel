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
    var postfix: [PostfixEvaluation.Token] { get }
}

extension ExpressionTokenProtocol {
    fileprivate static func serialize(
        postfix: [PostfixEvaluation.Token]) throws -> [[String: Any]] {

        let encoder = JSONEncoder()
        guard let string = String(data: try encoder.encode(postfix), encoding: .utf8) else {
            throw JSONError(
                kind: .dataEncodingError,
                description: "Could not encode postfix Data to utf8 String")
        }

        let postfixJSON = try JSON(json: string)
        let serializedPostfix = postfixJSON.serialized!
        return serializedPostfix as! [[String: Any]] // swiftlint:disable:this force_cast
    }

    func evaluate(with data: [String: Any]) throws -> Any? {
        let eval = PostfixEvaluation(postfix: postfix)
        return try eval.evaluate(with: data)
    }
}

struct ExpressionToken: ExpressionTokenProtocol {
    let id = "expression"

    let line: Int

    let infix: String
    let postfix: [PostfixEvaluation.Token]
    private let serializedPostfix: [[String: Any]]

    init(infix: String, line: Int) throws {
        let eval = try InfixEvaluation(expression: infix)
        self.postfix = eval.postfix
        self.line = line
        self.infix = infix
        self.serializedPostfix = try ExpressionToken.serialize(postfix: postfix)
    }

    init(infix: String, postfix: [PostfixEvaluation.Token], line: Int) {
        self.infix = infix
        self.postfix = postfix
        self.line = line
        // swiftlint:disable:next force_try
        self.serializedPostfix = try! ExpressionToken.serialize(postfix: postfix)
    }

    var serialized: [String: Any] {
        return ["id": id, "postfix": serializedPostfix, "infix": infix, "line": line]
    }
}

struct RawExpressionToken: ExpressionTokenProtocol {
    let id = "raw expression"

    let line: Int

    let infix: String
    let postfix: [PostfixEvaluation.Token]
    private let serializedPostfix: [[String: Any]]

    init(infix: String, line: Int) throws {
        let eval = try InfixEvaluation(expression: infix)

        self.postfix = eval.postfix
        self.infix = infix
        self.line = line
        self.serializedPostfix = try RawExpressionToken.serialize(postfix: postfix)
    }

    init(infix: String, postfix: [PostfixEvaluation.Token], line: Int) {
        self.infix = infix
        self.postfix = postfix
        self.line = line
        // swiftlint:disable:next force_try
        self.serializedPostfix = try! RawExpressionToken.serialize(postfix: postfix)
    }

    var serialized: [String: Any] {
        return ["id": id, "postfix": serializedPostfix, "infix": infix, "line": line]
    }
}

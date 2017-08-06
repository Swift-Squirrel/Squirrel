//
//  IfParser.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/5/17.
//
//

import Foundation

struct IfParser: ParseCommandProtocol {
    func parse(text: inout [String], prevChar: inout String) throws -> String {
        var cond = ""
        var char = ""
        repeat {
            guard text.count > 0 else {
                throw ParseError(kind: .unexpectedEnd, description: "Unexpected end while parsing: \(prefix+cond)")
            }
            char = text[0]
            text.remove(at: 0)
            cond += char
            prevChar = char
        } while char != "{"

        var components = cond.components(separatedBy: " ")
        guard components.count > 1, components.last! == "}" else {
            throw ParseError(kind: .syntaxError, description: "Syntax error in \(prefix + cond)")
        }
        components.removeLast()





    }

    let name = "If parser"

    let prefix = "\\if "
}

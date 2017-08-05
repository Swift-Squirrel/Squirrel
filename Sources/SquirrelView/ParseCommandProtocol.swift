//
//  ParseCommand.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

import Regex

protocol ParseCommandProtocol {
    var name: String { get }

    var prefix: String { get }

    func parse(text: inout [String], prevChar: inout String) throws -> String
}

struct ParseError: Error, CustomStringConvertible {
    enum ErrorKind {
        case partsNumber
        case unknownVariable(name: String)
        case unexpectedEnd
        case syntaxError
    }

    let kind: ErrorKind
    let description: String

}

struct ValueParser: ParseCommandProtocol {
    func parse(text: inout [String], prevChar: inout String) throws -> String {
        var content1 = ""
        var opened = 1
        while opened > 0 {
            guard text.count > 0 else {
                throw ParseError(kind: .unexpectedEnd, description: "Unexpected end while parsing: \(prefix + content1)")
            }
            let char = text[0]
            text.remove(at: 0)

            if char == "(" {
                opened += 1
            } else if char == ")" {
                opened -= 1
                if opened == 0 {
                    prevChar = char
                    break
                }
            }
            prevChar = char
            content1 += char
        }
        let co = content1

        content1 = Array(co.characters).map( { String(describing: $0) } ).filter( { $0 != " " } ).joined()
        if let value = ViewParser.get(name: content1) {
            return String(describing: value)
        } else {
            throw ParseError(kind: .unknownVariable(name: content1), description: "Unknown variable \(content1)")
        }
    }

    let name: String = "Value Parser"

    let prefix: String = "\\("

    let regex: Regex = Regex("[^\\\\]\\\\\\(\\s*?(\\S+?)\\s*?\\)")



}

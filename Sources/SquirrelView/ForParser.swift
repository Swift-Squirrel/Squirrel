//
//  ForParser.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/5/17.
//
//

struct ForParser: ParseCommandProtocol {
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

        let conds = cond.components(separatedBy: " ")

        guard conds.count == 4, conds[1] == "in", conds[3] == "{" else {
            throw ParseError(kind: .syntaxError, description: "Syntax error in \(prefix + cond)")
        }

        let variableName = conds[0]
        let source = conds[2]

        guard let items = ViewParser.get(name: source) as? [Any] else {
            throw ParseError(kind: .unknownVariable(name: source), description: "\(source) is unknown variable or is not array")
        }

        let prevValue = ViewParser.data[variableName]
        var res = ""
        var pomText = text
        for item in items {
            pomText = text
            ViewParser.data[variableName] = item
            res += try ViewParser.parse(text: &pomText, prevChar: &prevChar, partial: true)
        }
        text = pomText
        ViewParser.data[variableName] = prevValue
        return res


    }

    let name = "For parser"

    let prefix = "\\for "
}

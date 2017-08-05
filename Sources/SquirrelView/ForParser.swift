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

        let source: String
        let variableName: String
        let keyName: String?

        if conds.count == 4 {
            guard conds[1] == "in", conds[3] == "{" else {
                throw ParseError(kind: .syntaxError, description: "Syntax error in \(prefix + cond)")
            }
            variableName = conds[0]
            source = conds[2]
            keyName = nil
        } else {
            guard conds.count == 5, conds[2] == "in", conds[4] == "{" else {
                throw ParseError(kind: .syntaxError, description: "Syntax error in \(prefix + cond)")
            }
            source = conds[3]
            var pom = conds[1]
            pom.remove(at: pom.index(before: pom.endIndex))
            variableName = pom
            pom = conds[0]
            pom.remove(at: pom.startIndex)
            pom.remove(at: pom.index(before: pom.endIndex))
            keyName = pom
        }



        var res = ""
        if let keyName = keyName {
            let itms = ViewParser.get(name: source) as? [Any]
            guard let items = ViewParser.get(name: source) as? [String: Any] else {
                throw ParseError(kind: .unknownVariable(name: source), description: "\(source) is unknown variable or is not array")
            }
            let prevValue = ViewParser.data[variableName]
            let prevKey = ViewParser.data[keyName]
            var pomText = text
            for (key, value) in items {
                pomText = text
                ViewParser.data[keyName] = key
                ViewParser.data[variableName] = value
                res += try ViewParser.parse(text: &pomText, prevChar: &prevChar, partial: true)
            }
            text = pomText
            ViewParser.data[keyName] = prevKey
            ViewParser.data[variableName] = prevValue
        } else {
            guard let items = ViewParser.get(name: source) as? [Any] else {
                throw ParseError(kind: .unknownVariable(name: source), description: "\(source) is unknown variable or is not array")
            }
            let prevValue = ViewParser.data[variableName]
            var pomText = text
            for item in items {
                pomText = text
                ViewParser.data[variableName] = item
                res += try ViewParser.parse(text: &pomText, prevChar: &prevChar, partial: true)
            }
            text = pomText
            ViewParser.data[variableName] = prevValue
        }

        return res
    }

    let name = "For parser"

    let prefix = "\\for "
}

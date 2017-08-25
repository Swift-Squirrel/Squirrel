//
//  NutParser.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/6/17.
//
//

import PathKit
import SquirrelJSONEncoding

class NutParser: NutParserProtocol {

    private var content = ""
    private let name: String
    private var serializedTokens: [String: Any] = [:]
    private let viewType: ViewType

    private var _jsonSerialized: String = ""

    var jsonSerialized: String {
        return _jsonSerialized
    }

    private struct Constants {
        private init() {}
        static let separator = "\\"
    }

    private enum ViewType {
        case view
        case layout
        case subview
    }
    
    required init(content: String, name: String) {
        self.content = content
        self.name = name
        let typ = name.split(separator: "/", maxSplits: 1).first!
        switch typ {
        case "Layouts":
            viewType = .layout
        case "Views":
            viewType = .view
        default:
            viewType = .subview
        }
    }

    private func makeSeparations() -> [String] {
        var separatedPom = content.components(separatedBy: Constants.separator)
        if separatedPom.count > 1 {

            var index = 1
            let stop = separatedPom.count
            separatedPom.append("")
            while index < stop {
                if separatedPom[index] == "" {
                    separatedPom[index - 1] += Constants.separator + separatedPom[index + 1]
                    separatedPom[index + 1] = ""
                    index += 1
                }
                index += 1
            }
        }
        separatedPom = separatedPom.filter( { $0 != "" } )
        separatedPom.insert("", at: 0)
        return separatedPom
    }

    private func getRow(string: String) -> Int {
        var rowIndex: Int = 1
        string.characters.forEach({ (char) in
            if char == "\n" {
                rowIndex += 1
            }
        })

        return rowIndex
    }

    private func getRow(array: [String]) -> Int {
        let string = array.joined(separator: Constants.separator)
        return getRow(string: string)
    }
    private func getRow(array: ArraySlice<String>) -> Int {
        let string = array.joined(separator: Constants.separator)
        return getRow(string: string)
    }

    func tokenize() throws -> ViewToken {
        var separated = makeSeparations()
        var tokens = [NutTokenProtocol]()
        var title: TitleToken? = nil
        var layout: LayoutToken? = nil
        var index = separated.count - 1
        do {
            while index > 0 {
                let row = getRow(array: separated.prefix(index))
                let current = separated[index]
                var cont = false
                switch viewType {
                case .view:
                    if current.hasPrefix("Layout(\"") {
                        let tks = try parseLayout(text: current, row: row)
                        guard let layoutToken = (tks.last! as? LayoutToken) else {
                            throw NutParserError(
                                kind: .unknownInternalError(commandName: "\\Layout"),
                                row: getRow(
                                    string: separated.prefix(index).joined(separator: "\\")
                                )
                            )
                        }
                        layout = layoutToken
                        if tks.count == 2 {
                            tokens.append(tks.first!)
                        }
                    } else if current.hasPrefix("Title") {
                        let tks = try parseTitle(text: current, row: row)
                        guard let titleToken = (tks.last! as? TitleToken) else {
                            throw NutParserError(
                                kind: .unknownInternalError(commandName: "\\Title"),
                                row: getRow(
                                    string: separated.prefix(index).joined(separator: "\\")
                                )
                            )
                        }
                        title = titleToken
                        if tks.count == 2 {
                            tokens.append(tks.first!)
                        }
                    } else {
                        cont = true
                    }
                case .layout:
                    if current.hasPrefix("View()") {
                        tokens.append(contentsOf: parseView(text: current, row: row))
                    } else {
                        cont = true
                    }
                case .subview:
                    cont = true
                }
                if cont {
                    if current.hasPrefix("(") {
                        tokens.append(contentsOf: try parseExpression(text: current, row: row))
                    } else if current.hasPrefix("if ") {
                        tokens.append(contentsOf: try parseIf(text: current, row: row))
                    } else if current.hasPrefix("for ") {
                        tokens.append(contentsOf: try parseFor(text: current, row: row))
                    } else if current.hasPrefix("} else if ") {
                        tokens.append(contentsOf: try parseElseIf(text: current, row: row))
                    } else if current.hasPrefix("} else { ") || current.hasPrefix("} else {\n") {
                        tokens.append(contentsOf: parseElse(text: current, row: row))
                    } else if current.hasPrefix("}") {
                        var text = current
                        text.remove(at: text.startIndex)
                        tokens.append(TextToken(value: text))
                        tokens.append(EndBlockToken(row: row))
                    } else {
                        separated[index - 1] += current
                        separated[index] = ""
                    }
                }
                index -= 1
            }
            if separated.first! != "" {
                tokens.append(TextToken(value: separated.first!))
            }

            let reductedTokens = try doReduction(tokens: tokens)

            let tks = reductedTokens.reversed().map( { $0.serialized } )
            var res: [String: Any] = ["body": tks, "fileName": name]

            var head = [[String: Any]]()
            var headTokens = [NutHeadProtocol]()

            if let titleToken = title {
                head.append(titleToken.serialized)
                headTokens.append(titleToken)
            }
            if head.count > 0 {
                res["head"] = head
            }
            if let layout = layout {
                res["layout"] = layout.serialized
            }
            serializedTokens = res
            _jsonSerialized = try! JSONCoding.encodeJSON(object: res)
            let viewBody = ViewToken(name: name, head: headTokens, body: reductedTokens.reversed(), layout: layout)
            return viewBody
        } catch var error as NutParserError {
            guard error.name == nil else {
                throw error
            }
            error.name = name
            throw error
        }
    }

    private func doReduction(tokens originalTokens: [NutTokenProtocol]) throws -> [NutTokenProtocol] {
        var tokens = originalTokens
        var index = 0
        while index < tokens.count {
            let current = tokens[index]
            switch current {
            case var forInToken as ForInToken:
                var backIndex = index - 1
                var body = [NutTokenProtocol]()
                var foundEnd = false
                while !foundEnd && backIndex > 0 {
                    if tokens[backIndex] is EndBlockToken {
                        foundEnd = true
                    } else {
                        body.append(tokens[backIndex])
                    }
                    tokens.remove(at: backIndex)
                    index -= 1
                    backIndex -= 1
                }
                if foundEnd {
                    forInToken.setBody(body: body)
                    tokens[index] = forInToken
                } else {
                    throw NutParserError(kind: .unexpectedEnd(reading: forInToken.id), row: forInToken.row, description: "\\} not found")
                }

            case var ifToken as IfTokenProtocol:
                var backIndex = index - 1
                var body = [NutTokenProtocol]()
                var elseToken: NutTokenProtocol?
                var foundEnd = false
                while !foundEnd && backIndex > 0 {
                    if let elT = tokens[backIndex] as? ElseToken {
                        foundEnd = true
                        elseToken = elT
                    } else if let elifT = tokens[backIndex] as? ElseIfToken {
                        foundEnd = true
                        elseToken = elifT
                    } else if tokens[backIndex] is EndBlockToken {
                        foundEnd = true
                    } else {
                        body.append(tokens[backIndex])
                    }
                    tokens.remove(at: backIndex)
                    index -= 1
                    backIndex -= 1
                }
                if foundEnd {
                    ifToken.setThen(body: body)
                    if let elseToken = elseToken {
                        if let el = elseToken as? ElseToken {
                            ifToken.setElse(body: el.getBody())
                        } else if let el = elseToken as? ElseIfToken {
                            var ifT: IfToken
                            if let variable = el.variable {
                                ifT = IfToken(variable: variable, condition: el.getCondition(), row: el.row)
                            } else {
                                ifT = IfToken(condition: el.getCondition(), row: el.row)
                            }
                            ifT.setThen(body: el.getThen())
                            if let elseBlock = el.getElse() {
                                ifT.setElse(body: elseBlock)
                            }
                            ifToken.setElse(body: [ifT])
                        }
                    }
                    tokens[index] = ifToken
                } else {
                    throw NutParserError(kind: .unexpectedEnd(reading: ifToken.id), row: ifToken.row, description: "\\} not found") // TODO
                }

            case var elseToken as ElseToken:
                var backIndex = index - 1
                var body = [NutTokenProtocol]()
                var foundEnd = false
                while !foundEnd && backIndex > 0 {
                    if tokens[backIndex] is EndBlockToken {
                        foundEnd = true
                    } else {
                        body.append(tokens[backIndex])
                    }
                    tokens.remove(at: backIndex)
                    index -= 1
                    backIndex -= 1
                }
                if foundEnd {
                    elseToken.setBody(body: body)
                    tokens[index] = elseToken
                } else {
                    throw NutParserError(kind: .unexpectedEnd(reading: elseToken.id), row: elseToken.row, description: "\\} not found") // TODO
                }
            default:
                break
            }
            index += 1
        }
        return tokens
    }
}

extension NutParser {
    private func parseFor(text: String, row: Int) throws -> [NutTokenProtocol] {
        let chars = Array(text.characters).map( { String(describing: $0) } )
        var prevChar = ""
        var inString = false
        var charIndex = 0
        for char in chars {
            if char == "{" && !inString && prevChar == " " {
                let start = text.index(text.startIndex, offsetBy: 3)
                let end = text.index(text.startIndex, offsetBy: charIndex)

                let stm = String(text[start..<end])

                let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
                let text = String(text[stringIndex...])

                guard stm != "" else {
                    let expected = ["for <variable: Any> in <array: [Any]> {", "for (<key: String>, <value: Any>) in <dictionary: [String: Value> {"]
                    throw NutParserError(kind: .syntaxError(expected: expected, got: stm), row: row)
                }
                let separated = stm.components(separatedBy: " ")
                var key: String? = nil
                var variable = ""
                var array = ""
                if separated.count == 5 && separated[2] == "in" {
                    variable = separated[1]
                    array = separated[3]
                } else if separated.count == 6 && separated[3] == "in"
                    && separated[1].hasPrefix("(") && separated[1].hasSuffix(",") && separated[2].hasSuffix(")")
                    && separated[1].characters.count > 2 && separated[2].characters.count > 1 {
                    key = separated[1]
                    key!.remove(at: key!.startIndex)
                    key!.remove(at: key!.index(before: key!.endIndex))
                    variable = separated[2]
                    variable.remove(at: variable.endIndex)
                    array = separated[4]
                } else {
                    let expected = ["for <variable: Any> in <array: [Any]> {", "for (<key: String>, <value: Any>) in <dictionary: [String: Value> {"]
                    throw NutParserError(kind: .syntaxError(expected: expected, got: stm), row: row)
                }

                let token = ForInToken(key: key, variable: variable, array: array, row: row)

                if text == "" {
                    return [token]
                }
                return [TextToken(value: text), token]

            } else if char == "\"" && prevChar != "\\" {
                inString = !inString
            }
            charIndex += 1
            prevChar = char
        }
        let expected = ["for <variable: Any> in <array: [Any]> {", "for (<key: String>, <value: Any>) in <dictionary: [String: Value> {"]
        throw NutParserError(kind: .syntaxError(expected: expected, got: text), row: row, description: "'{' not found")
    }

    private func parseView(text: String, row: Int) -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 6)
        let text = String(text[stringIndex...])
        let viewToken = InsertViewToken(row: row)
        if text == "" {
            return [viewToken]
        } else {
            return [TextToken(value: text), viewToken]
        }
    }

    private func parseTitle(text: String, row: Int) throws -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 5)
        let text = String(text[stringIndex...])
        let res = try parseExpression(text: text, row: row)
        if let expr = res.last! as? ExpressionToken {
            let titleToken = TitleToken(expression: expr, row: row)
            if res.count == 2 {
                return [res[0], titleToken]
            } else {
                return [titleToken]
            }
        }
        throw NutParserError(kind: .expressionError, row: row)
    }

    private func parseLayout(text: String, row: Int) throws -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 8)
        let text = String(text[stringIndex...])
        var inString = true
        var prevChar = ""
        var charIndex = 0
        for char in text {
            if char == ")" && prevChar == "\"" && !inString {
                break
            } else if char == "\"" && prevChar != "\\" {
                inString = !inString
            }
            prevChar = String(char)
            charIndex += 1
        }
        guard charIndex < text.count else {
            throw NutParserError(kind: .syntaxError(expected: ["Layout(\"<name>\")"], got: text), row: row, description: "missing '\")'")
        }
        let finalStringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
        var name = String(text[..<finalStringIndex])
        name.remove(at: name.index(before: name.endIndex))
        name.remove(at: name.index(before: name.endIndex))
        let finalText = String(text[finalStringIndex...])
        let layoutToken = LayoutToken(name: "Layouts." + name, row: row)
        if finalText == "" {
            return [layoutToken]
        }
        return [TextToken(value: finalText), layoutToken]
    }

    fileprivate func parseElseIf(text: String, row: Int) throws -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 7)
        let text = String(text[stringIndex...])
        let chars = Array(text.characters).map( { String(describing: $0) } )
        var prevChar = ""
        var inString = false
        var charIndex = 0
        for char in chars {
            if char == "{" && !inString && prevChar == " " {
                let start = text.index(text.startIndex, offsetBy: 3)
                let end = text.index(text.startIndex, offsetBy: charIndex)
                let range = start..<end

                let condition = String(text[range])

                let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
                let text = String(text[stringIndex...])
                guard condition != "" else {
                    let expected = ["} else if <expression: Bool> {", "} else if let <variableName: Any> = <expression: Any?> {"]
                    throw NutParserError(kind: .syntaxError(expected: expected, got: text), row: row, description: "empty <expression>")

                }
                let elsifToken = ElseIfToken(condition: condition, row: row)
                if text == "" {
                    return [elsifToken]
                }
                return [TextToken(value: text), elsifToken]

            } else if char == "\"" && prevChar != "\\" {
                inString = !inString
            }
            charIndex += 1
            prevChar = char
        }
        let expected = ["} else if <expression: Bool> {", "} else if let <variableName: Any> = <expression: Any?> {"]
        throw NutParserError(kind: .syntaxError(expected: expected, got: text), row: row, description: "'{' not found")
    }

    fileprivate func parseElse(text: String, row: Int) -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 9)
        let text = String(text[stringIndex...])
        let elseToken = ElseToken(row: row)
        if text == "" {
            return [elseToken]
        }
        return [TextToken(value: text), elseToken]
    }

    fileprivate func parseExpression(text: String, row: Int) throws -> [NutTokenProtocol] {
        let chars = Array(text.characters).map( { String(describing: $0) })
        var prevChar = ""
        var inString = false
        var charIndex = 0
        var opened = 0
        for char in chars {
            if char == ")" && !inString {
                opened -= 1
                if opened == 0 {
                    break
                }
            } else if char == "(" && !inString {
                opened += 1
            } else if char == "\"" && prevChar != "\\" {
                inString = !inString
            }
            prevChar = char
            charIndex += 1
        }
        guard opened == 0 else {
            throw NutParserError(kind: .syntaxError(expected: ["(<expression: Any>)"], got: text), row: row, description: "missing ')'")
        }
        let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
        var expression = String(text[..<stringIndex])
        expression.remove(at: expression.startIndex)
        expression.remove(at: expression.index(before: expression.endIndex))
        let text = String(text[stringIndex...])
        if let expressionToken = ExpressionToken(infix: expression, row: row) {
            if text == "" {
                return [expressionToken]
            }
            return [TextToken(value: text), expressionToken]
        }
        throw NutParserError(kind: .expressionError, row: row)
    }

    fileprivate func parseIf(text: String, row: Int) throws -> [NutTokenProtocol] {
        let chars = Array(text.characters).map( { String(describing: $0) } )
        var prevChar = ""
        var inString = false
        var charIndex = 0
        for char in chars {
            if char == "{" && !inString && prevChar == " " {
                let start = text.index(text.startIndex, offsetBy: 3)
                let end = text.index(text.startIndex, offsetBy: charIndex)
                let range = start..<end

                let condition = String(text[range])

                let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
                let text = String(text[stringIndex...])
                guard condition != "" else {
                    let expected = ["if <expression: Bool> {", "if let <variableName: Any> = <expression: Any?> {"]
                    throw NutParserError(kind: .syntaxError(expected: expected, got: text), row: row, description: "empty <expression>")
                }
                let token = IfToken(condition: condition, row: row)
                if text == "" {
                    return [token]
                }
                return [TextToken(value: text), token]
                
            } else if char == "\"" && prevChar != "\\" {
                inString = !inString
            }
            charIndex += 1
            prevChar = char
        }
        let expected = ["if <expression: Bool> {", "if let <variableName: Any> = <expression: Any?> {"]
        throw NutParserError(kind: .syntaxError(expected: expected, got: text), row: row, description: "'{' not found")
    }
}

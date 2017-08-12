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
    private var serializedTokens: [String: Any] = [:]

    private var _jsonSerialized: String = ""

    var jsonSerialized: String {
        return _jsonSerialized
    }

    private struct Constants {
        private init() {}
        static let separator = "\\"
    }
    
    required init(content: String) {
        self.content = content
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

    private func getRow(string: String) -> UInt {
        var rowIndex: UInt = 0
        string.characters.forEach({ (char) in
            if char == "\n" {
                rowIndex += 1
            }
        })

        return rowIndex
    }

    func tokenize() throws -> ViewToken {
        var separated = makeSeparations()
        var tokens = [NutTokenProtocol]()
        var title: TitleToken? = nil
        var index = separated.count - 1
        while index > 0 {
            let current = separated[index]
            if current.hasPrefix("(") {
                tokens.append(contentsOf: parseExpression(text: current))
            } else if current.hasPrefix("Title") {
                let tks = try parseTitle(text: current)
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
            } else if current.hasPrefix("if ") {
                tokens.append(contentsOf: parseIf(text: current))
            } else if current.hasPrefix("for ") {
                tokens.append(contentsOf: parseFor(text: current))
            } else if current.hasPrefix("} else if ") {
                tokens.append(contentsOf: parseElseIf(text: current))
            } else if current.hasPrefix("} else { ") {
                tokens.append(contentsOf: parseElse(text: current))
            } else if current.hasPrefix("}") {
                var text = current
                text.remove(at: text.startIndex)
                tokens.append(TextToken(value: text))
                tokens.append(EndBlockToken())
            } else {
                separated[index - 1] += current
                separated[index] = ""
            }
            index -= 1
        }
        if separated.first! != "" {
            tokens.append(TextToken(value: separated.first!))
        }

        let reductedTokens = doReduction(tokens: tokens)

        let tks = reductedTokens.reversed().map( { $0.serialized } )
        var res: [String: Any] = ["body": tks]

        var head = [[String: Any]]()
        var headTokens = [NutHeadProtocol]()

        if let titleToken = title {
            head.append(titleToken.serialized)
            headTokens.append(titleToken)
        }
        if head.count > 0 {
            res["head"] = head
        }
        serializedTokens = res
        _jsonSerialized = try! JSONCoding.encodeJSON(object: res)
        let viewBody = ViewToken(head: headTokens, body: reductedTokens.reversed())
        return viewBody
    }

    private func doReduction(tokens originalTokens: [NutTokenProtocol]) -> [NutTokenProtocol] {
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
                    // TODO
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
                            var ifT = IfToken(condition: el.getCondition())
                            ifT.setThen(body: el.getThen())
                            if let elseBlock = el.getElse() {
                                ifT.setElse(body: elseBlock)
                            }
                            ifToken.setElse(body: [ifT])
                        }
                    }
                    tokens[index] = ifToken
                } else {
                    // TODO
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
                    // TODO
                }
            default:
                break
            }
            index += 1
        }
        return tokens
    }

    private func parseFor(text: String) -> [NutTokenProtocol] {
        let chars = Array(text.characters).map( { String(describing: $0) } )
        var prevChar = ""
        var inString = false
        var charIndex = 0
        for char in chars {
            if char == "{" && !inString && prevChar == " " {
                let start = text.index(text.startIndex, offsetBy: 3)
                let end = text.index(text.startIndex, offsetBy: charIndex)
                let range = start..<end

                let stm = text.substring(with: range)

                let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
                let text = text.substring(from: stringIndex)

                guard stm != "" else {
                    return []
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
                    return [] // TODO
                }

                let token = ForInToken(key: key, variable: variable, array: array)

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
        return []
    }

    private func parseTitle(text: String) throws -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 5)
        let text = text.substring(from: stringIndex)
        let res = parseExpression(text: text)
        if let expr = res.last! as? ExpressionToken {
        let titleToken = TitleToken(expression: expr)
            if res.count == 2 {
                return [res[0], titleToken]
            } else {
                return [titleToken]
            }
        }
        return []
    }

    private func parseElseIf(text: String) -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 7)
        let text = text.substring(from: stringIndex)
        let chars = Array(text.characters).map( { String(describing: $0) } )
        var prevChar = ""
        var inString = false
        var charIndex = 0
        for char in chars {
            if char == "{" && !inString && prevChar == " " {
                let start = text.index(text.startIndex, offsetBy: 3)
                let end = text.index(text.startIndex, offsetBy: charIndex)
                let range = start..<end

                let condition = text.substring(with: range)

                let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
                let text = text.substring(from: stringIndex)
                guard condition != "" else {
                    return []
                }
                if text == "" {
                    return [ElseIfToken(condition: condition)]
                } 
                return [TextToken(value: text), ElseIfToken(condition: condition)]

            } else if char == "\"" && prevChar != "\\" {
                inString = !inString
            }
            charIndex += 1
            prevChar = char
        }
        return []

    }

    private func parseElse(text: String) -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 9)
        let text = text.substring(from: stringIndex)
        if text == "" {
            return [ElseToken()]
        }
        return [TextToken(value: text), ElseToken()]
    }

    private func parseExpression(text: String) -> [NutTokenProtocol] {
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
        let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
        var expression = text.substring(to: stringIndex)
        expression.remove(at: expression.startIndex)
        expression.remove(at: expression.index(before: expression.endIndex))
        let text = text.substring(from: stringIndex)
        if let expressionToken = ExpressionToken(infix: expression) {
            if text == "" {
                return [expressionToken]
            }
            return [TextToken(value: text), expressionToken]
        }
        return [] // TODO
    }

    private func parseIf(text: String) -> [NutTokenProtocol] {
        let chars = Array(text.characters).map( { String(describing: $0) } )
        var prevChar = ""
        var inString = false
        var charIndex = 0
        for char in chars {
            if char == "{" && !inString && prevChar == " " {
                let start = text.index(text.startIndex, offsetBy: 3)
                let end = text.index(text.startIndex, offsetBy: charIndex)
                let range = start..<end

                let condition = text.substring(with: range)

                let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
                let text = text.substring(from: stringIndex)
                guard condition != "" else {
                    return []
                }
                if text == "" {
                    return [IfToken(condition: condition)]
                }
                return [TextToken(value: text), IfToken(condition: condition)]

            } else if char == "\"" && prevChar != "\\" {
                inString = !inString
            }
            charIndex += 1
            prevChar = char
        }
        return []
    }
}

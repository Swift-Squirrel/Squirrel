//
//  NutInterpreter.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/6/17.
//
//

import PathKit
import SquirrelJSONEncoding

public class NutInterpreter: NutInterpreterProtocol {

    private let resources: Path
    private let storage: Path
    private var content = ""

    private struct Constants {
        private init() {}
        static let separator = "\\"
    }
    
    public required init(resources: Path, storage: Path) {
        self.resources = resources
        self.storage = storage
    }

    public func setContent(content: String) {
        self.content = content
    }

    public func tokenize() throws -> String {
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
        var tokens = [NutTokenProtocol]()
        var separated = separatedPom
        var index = separated.count - 1
        while index > 0 {
            let current = separated[index]
            if current.hasPrefix("(") {
                tokens.append(contentsOf: parseExpression(text: current))
            } else if current.hasPrefix("if ") {
                tokens.append(contentsOf: parseIf(text: current))
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
        let res = ["body": tks]
        return try! JSONCoding.encodeJSON(object: res)
    }

    private func doReduction(tokens originalTokens: [NutTokenProtocol]) -> [NutTokenProtocol] {
        var tokens = originalTokens
        var index = 0
        while index < tokens.count {
            let current = tokens[index]
            switch current {
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
        let expression = text.substring(to: stringIndex)
        let text = text.substring(from: stringIndex)
        if text == "" {
            return [ExpressionToken(infix: expression)]
        }
        return [TextToken(value: text), ExpressionToken(infix: expression)]
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

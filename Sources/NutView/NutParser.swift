//
//  NutParser.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/6/17.
//
//

import PathKit
import SquirrelJSONEncoding
import Regex
// swiftlint:disable cyclomatic_complexity
// swiftlint:disable function_body_length
// swiftlint:disable file_length
// swiftlint:disable:next type_body_length
class NutParser: NutParserProtocol {

    private var content = ""
    private let name: String
    private var serializedTokens: [String: Any] = [:]
    private let viewType: ViewType

    private let simpleVariable = (regex: "^[a-zA-Z]\\w*$", value: Regex("^[a-zA-Z]\\w*$"))
    private let chainedVariable = (regex: "^[a-zA-Z]\\w*(?:\\.[a-zA-Z]\\w*)*$",
                                   value: Regex("^[a-zA-Z]\\w*(?:\\.[a-zA-Z]\\w*)*$"))

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
        separatedPom = separatedPom.filter({ $0 != "" })
        separatedPom.insert("", at: 0)
        return separatedPom
    }

    private func getLine(string: String) -> Int {
        var lineIndex: Int = 1
        string.forEach({ (char) in
            if char == "\n" {
                lineIndex += 1
            }
        })

        return lineIndex
    }

    private func getLine(array: [String]) -> Int {
        let string = array.joined(separator: Constants.separator)
        return getLine(string: string)
    }
    private func getLine(array: ArraySlice<String>) -> Int {
        let string = array.joined(separator: Constants.separator)
        return getLine(string: string)
    }

    func tokenize() throws -> ViewToken {
        var separated = makeSeparations()
        var tokens = [NutTokenProtocol]()
        var title: TitleToken? = nil
        var layout: LayoutToken? = nil
        var index = separated.count - 1
        do {
            while index > 0 {
                let line = getLine(array: separated.prefix(index))
                let current = separated[index]
                var cont = false
                switch viewType {
                case .view:
                    if current.hasPrefix("Layout(\"") {
                        let tks = try parseLayout(text: current, line: line)
                        guard let layoutToken = (tks.last! as? LayoutToken) else {
                            throw NutParserError(
                                kind: .unknownInternalError(commandName: "\\Layout"),
                                line: getLine(
                                    string: separated.prefix(index).joined(separator: "\\")
                                )
                            )
                        }
                        layout = layoutToken
                        if tks.count == 2 {
                            tokens.append(tks.first!)
                        }
                    } else if current.hasPrefix("Title") {
                        let tks = try parseTitle(text: current, line: line)
                        guard let titleToken = (tks.last! as? TitleToken) else {
                            throw NutParserError(
                                kind: .unknownInternalError(commandName: "\\Title"),
                                line: getLine(
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
                        tokens.append(contentsOf: parseView(text: current, line: line))
                    } else {
                        cont = true
                    }
                case .subview:
                    cont = true
                }
                if cont {
                    if current.hasPrefix("(") {
                        tokens.append(contentsOf: try parseExpression(text: current, line: line))
                    } else if current.hasPrefix("RawValue(") {
                        tokens.append(contentsOf: try parseRawExpression(text: current, line: line))
                    } else if current.hasPrefix("Date(") {
                        tokens.append(contentsOf: try parseDate(text: current, line: line))
                    } else if current.hasPrefix("if ") {
                        tokens.append(contentsOf: try parseIf(text: current, line: line))
                    } else if current.hasPrefix("Subview(\"") {
                        let tks = try parseSubview(text: current, line: line)
                        tokens.append(contentsOf: tks)
                    } else if current.hasPrefix("for ") {
                        tokens.append(contentsOf: try parseFor(text: current, line: line))
                    } else if current.hasPrefix("} else if ") {
                        tokens.append(contentsOf: try parseElseIf(text: current, line: line))
                    } else if current.hasPrefix("} else { ") || current.hasPrefix("} else {\n") {
                        tokens.append(contentsOf: parseElse(text: current, line: line))
                    } else if current.hasPrefix("}") {
                        var text = current
                        text.remove(at: text.startIndex)
                        tokens.append(TextToken(value: text))
                        tokens.append(EndBlockToken(line: line))
                    } else {
                        separated[index - 1] += "\\" + current
                        separated[index] = ""
                    }
                }
                index -= 1
            }
            if separated.first! != "" {
                tokens.append(TextToken(value: String(separated.first!.dropFirst())))
            }

            let reductedTokens = try doReduction(tokens: tokens)

            let tks = reductedTokens.reversed().map({ $0.serialized })
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
            // swiftlint:disable:next force_try
            _jsonSerialized = try! JSONCoding.encodeJSON(object: res)
            let viewBody = ViewToken(
                name: name,
                head: headTokens,
                body: reductedTokens.reversed(),
                layout: layout)

            return viewBody
        } catch var error as NutParserError {
            guard error.name == nil else {
                throw error
            }
            error.name = name
            throw error
        }
    }

    private func doReduction(tokens originalTokens: [NutTokenProtocol])
        throws -> [NutTokenProtocol] {

        var tokens = originalTokens
        var index = 0
        var opened = [NutCommandTokenProtocol]()
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
                    opened.removeLast()
                } else {
                    throw NutParserError(
                        kind: .unexpectedEnd(reading: forInToken.id),
                        line: forInToken.line,
                        description: "\\} not found")
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
                        opened.removeLast()
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
                                ifT = IfToken(
                                    variable: variable,
                                    condition: el.getCondition(),
                                    line: el.line)
                            } else {
                                ifT = IfToken(condition: el.getCondition(), line: el.line)!
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
                    throw NutParserError(
                        kind: .unexpectedEnd(reading: ifToken.id),
                        line: ifToken.line,
                        description: "\\} not found")
                }

            case var elseToken as ElseToken:
                var backIndex = index - 1
                var body = [NutTokenProtocol]()
                var foundEnd = false
                while !foundEnd && backIndex > 0 {
                    if tokens[backIndex] is EndBlockToken {
                        foundEnd = true
                        opened.removeLast()
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
                    throw NutParserError(
                        kind: .unexpectedEnd(reading: elseToken.id),
                        line: elseToken.line,
                        description: "\\} not found")
                }
            case let endBlock as EndBlockToken:
                opened.append(endBlock)
            default:
                break
            }
            index += 1
        }
        guard opened.isEmpty else {
            let endBlock = opened.last!
            throw NutParserError(kind: .unexpectedBlockEnd, line: endBlock.line)
        }
        return tokens
    }
}

extension NutParser {
    private func parseDate(text: String, line: Int) throws -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 5)
        let text = String(text[stringIndex...])
        let chars = text.map({ String(describing: $0) })
        var prevChar = ""
        var charIndex = 0
        var inString = false
        var formatIndex = 0
        var date: ExpressionToken!
        for char in chars {
            if char == "," && !inString {
                let finalStringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
                var dateString = String(text[..<finalStringIndex])
                dateString.removeLast()
                guard let datePom = ExpressionToken(infix: dateString, line: line) else {
                    throw NutParserError(
                        kind: .expressionError,
                        line: line,
                        description: "Could not resolve '\(dateString)'")
                }
                date = datePom
                charIndex += 1
                formatIndex = charIndex
                continue
            } else if char == "\"" && prevChar != "\\" {
                inString = !inString
            } else if char == ")" && !inString {
                break
            }
            prevChar = char
            charIndex += 1
        }
        guard charIndex < text.count else {
            throw NutParserError(
                kind: .syntaxError(
                    expected: ["Date(<expression: Double>, format: <expression: String>)",
                               "Date(<expression: Double>)"],
                    got: text),
                line: line,
                description: "missing '\")'")
        }
        guard charIndex > 0 else {
            throw NutParserError(
                kind: .syntaxError(
                    expected: ["Date(<expression: Double>, format: <expression: String>)",
                               "Date(<expression: Double>)"],
                    got: text),
                line: line)
        }
        let format: ExpressionToken?
        if formatIndex > 0 {
            let formatStringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
            let formatIndex = text.index(text.startIndex, offsetBy: formatIndex)
            let formatArg = String(text[formatIndex..<formatStringIndex])
            guard formatArg.hasPrefix(" format: ") else {
                throw NutParserError(
                    kind: .syntaxError(expected: [" format: <expression: String>"], got: formatArg),
                    line: line)
            }
            let formatOffset = formatArg.index(formatArg.startIndex, offsetBy: 9)
            var formatExpr = String(formatArg[formatOffset...])
            formatExpr.removeLast()
            guard let formatPom = ExpressionToken(infix: formatExpr, line: line) else {
                throw NutParserError(
                    kind: .expressionError,
                    line: line,
                    description: "Could not resolve '\(formatExpr)'")
            }
            format = formatPom
        } else {
            format = nil
            let dateStringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
            var dateString = String(text[..<dateStringIndex])
            dateString.removeLast()
            guard let datePom = ExpressionToken(infix: dateString, line: line) else {
                throw NutParserError(
                    kind: .expressionError,
                    line: line,
                    description: "Could not resolve '\(dateString)'")
            }
            date = datePom
        }
        let textIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
        let textToken = TextToken(value: String(text[textIndex...]))
        return [textToken, DateToken(date: date, format: format, line: line)]
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    private func parseFor(text: String, line: Int) throws -> [NutTokenProtocol] {
        let expected = [
            "for <variable: Any> in <array: [Any]> {",
            "for (<key: String>, <value: Any>) in <dictionary: [String: Value> {"
        ]

        let chars = text.map({ String(describing: $0) })
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
                    throw NutParserError(
                        kind: .syntaxError(expected: expected, got: stm),
                        line: line)
                }
                let separated = stm.components(separatedBy: " ")
                var key: String? = nil
                var variable = ""
                var array = ""
                if separated.count == 5 && separated[2] == "in" {
                    variable = separated[1]
                    array = separated[3]

                    if variable.contains(",") {
                        throw NutParserError(
                            kind: .syntaxError(expected: expected, got: stm),
                            line: line)
                    }
                } else if separated.count == 6 && separated[3] == "in"
                    && separated[1].hasPrefix("(") && separated[1].hasSuffix(",")
                    && separated[2].hasSuffix(")")
                    && separated[1].count > 2 && separated[2].count > 1 {

                    key = separated[1]
                    key!.removeFirst()
                    key!.removeLast()
                    variable = separated[2]
                    variable = String(variable.dropLast())
                    array = separated[4]
                } else {
                    throw NutParserError(
                        kind: .syntaxError(expected: expected, got: stm),
                        line: line)
                }
                if let keyValue = key {
                    guard checkSimple(variable: keyValue) else {
                        throw NutParserError(
                            kind: .wrongSimpleVariable(
                                name: keyValue,
                                in: "for\(stm){",
                                regex: simpleVariable.regex),
                            line: line)
                    }
                }
                guard checkSimple(variable: variable) else {
                    throw NutParserError(
                        kind: .wrongSimpleVariable(
                            name: variable,
                            in: "for\(stm){",
                            regex: simpleVariable.regex),
                        line: line)
                }
                guard checkChained(variable: array) else {
                    throw NutParserError(
                        kind: .wrongChainedVariable(
                            name: array,
                            in: "for\(stm){",
                            regex: chainedVariable.regex),
                        line: line)
                }
                let token = ForInToken(key: key, variable: variable, array: array, line: line)

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
        throw NutParserError(
            kind: .syntaxError(expected: expected, got: text),
            line: line,
            description: "'{' not found")
    }

    private func parseView(text: String, line: Int) -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 6)
        let text = String(text[stringIndex...])
        let viewToken = InsertViewToken(line: line)
        if text == "" {
            return [viewToken]
        } else {
            return [TextToken(value: text), viewToken]
        }
    }

    private func parseTitle(text: String, line: Int) throws -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 5)
        let text = String(text[stringIndex...])
        let res = try parseExpression(text: text, line: line)
        if let expr = res.last! as? ExpressionToken {
            let titleToken = TitleToken(expression: expr, line: line)
            if res.count == 2 {
                return [res[0], titleToken]
            } else {
                return [titleToken]
            }
        }
        throw NutParserError(kind: .expressionError, line: line)
    }

    private func parseLayout(text: String, line: Int) throws -> [NutTokenProtocol] {
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
            throw NutParserError(
                kind: .syntaxError(expected: ["Layout(\"<name>\")"], got: text),
                line: line,
                description: "missing '\")'")
        }
        let finalStringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
        var name = String(text[..<finalStringIndex])
        name.remove(at: name.index(before: name.endIndex))
        name.remove(at: name.index(before: name.endIndex))
        let finalText = String(text[finalStringIndex...])
        let layoutToken = LayoutToken(name: "Layouts." + name, line: line)
        if finalText == "" {
            return [layoutToken]
        }
        return [TextToken(value: finalText), layoutToken]
    }

    private func parseSubview(text: String, line: Int) throws -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 9)
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
            throw NutParserError(
                kind: .syntaxError(
                    expected: ["Subview(\"<name>\")"],
                    got: text),
                line: line,
                description: "missing '\")'")
        }
        let finalStringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
        var name = String(text[..<finalStringIndex])
        name.remove(at: name.index(before: name.endIndex))
        name.remove(at: name.index(before: name.endIndex))
        let finalText = String(text[finalStringIndex...])
        let subviewToken = SubviewToken(name: "Subviews." + name, line: line)
        if finalText == "" {
            return [subviewToken]
        }
        return [TextToken(value: finalText), subviewToken]
    }

    fileprivate func parseElseIf(text: String, line: Int) throws -> [NutTokenProtocol] {
        let expected = [
            "} else if <expression: Bool> {",
            "} else if let <variableName: Any> = <expression: Any?> {"
        ]

        let stringIndex = text.index(text.startIndex, offsetBy: 10)
        let text = String(text[stringIndex...])
        let chars = text.map({ String(describing: $0) })
        var prevChar = ""
        var inString = false
        var charIndex = 0
        guard text.first != "{" else {
            throw NutParserError(
                kind: .syntaxError(expected: expected, got: "} else if {"),
                line: line,
                description: "empty <expression>")
        }
        guard !text.hasPrefix("let {") else {
            throw NutParserError(
                kind: .syntaxError(expected: expected, got: "} else if let {"),
                line: line,
                description: "empty <expression>")
        }
        for char in chars {
            if char == "{" && !inString && prevChar == " " {
                let end = text.index(text.startIndex, offsetBy: charIndex)

                let condition = String(text[..<end].dropLast())

                let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
                let text = String(text[stringIndex...])
                guard condition != "" else {
                    throw NutParserError(
                        kind: .syntaxError(
                            expected: expected,
                            got: "} else if " + condition + " {"),
                        line: line,
                        description: "empty <expression>")

                }
                guard let elsifToken = ElseIfToken(condition: condition, line: line) else {
                    throw NutParserError(
                        kind: .syntaxError(
                            expected: expected,
                            got: "} else if " + condition + " {"),
                        line: line)
                }
                if let variable = elsifToken.variable {
                    guard checkSimple(variable: variable) else {
                        throw NutParserError(
                            kind: .wrongSimpleVariable(
                                name: variable,
                                in: "} else if " + condition + " {", regex: simpleVariable.regex),
                            line: line)
                    }
                    guard checkSimple(variable: elsifToken.condition) else {
                        throw NutParserError(
                            kind: .wrongChainedVariable(
                                name: elsifToken.condition,
                                in: "} else if " + condition + " {", regex: chainedVariable.regex),
                            line: line)
                    }
                }
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
        throw NutParserError(
            kind: .syntaxError(
                expected: expected,
                got: "} else if \(text)"),
            line: line,
            description: "'{' not found")
    }

    fileprivate func parseElse(text: String, line: Int) -> [NutTokenProtocol] {
        let stringIndex = text.index(text.startIndex, offsetBy: 9)
        let text = String(text[stringIndex...])
        let elseToken = ElseToken(line: line)
        if text == "" {
            return [elseToken]
        }
        return [TextToken(value: text), elseToken]
    }

    private func parseRawExpression(text: String, line: Int) throws -> [NutTokenProtocol] {
        let text = String(text[text.index(text.startIndex, offsetBy: 8)...])
        let chars = text.map({ String($0) })
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
            throw NutParserError(
                kind: .syntaxError(
                    expected: ["RawValue(<expression: Any>)"],
                    got: "RawValue" + text),
                line: line,
                description: "missing ')'")
        }
        let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
        var expression = String(text[..<stringIndex])
        guard expression != "()" else {
            throw NutParserError(
                kind: .syntaxError(
                    expected: ["RawValue(<expression: Any>)"],
                    got: "RawValue\(expression)"),
                line: line,
                description: "Empty expression")
        }
        expression.removeLast()
        expression.removeFirst()
        let text1 = String(text[stringIndex...])
        if let expressionToken = RawExpressionToken(infix: expression, line: line) {
            if text1 == "" {
                return [expressionToken]
            }
            return [TextToken(value: text1), expressionToken]
        }
        throw NutParserError(kind: .expressionError, line: line)
    }

    fileprivate func parseExpression(text: String, line: Int) throws -> [NutTokenProtocol] {
        let expected = ["(<expression: Any>)"]
        let chars = text.map({ String(describing: $0) })
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
            throw NutParserError(
                kind: .syntaxError(expected: expected, got: text),
                line: line,
                description: "missing ')'")
        }
        let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
        var expression = String(text[..<stringIndex])
        guard expression != "()" else {
            throw NutParserError(
                kind: .syntaxError(expected: expected, got: expression),
                line: line,
                description: "Empty expression")
        }
        expression.removeLast()
        expression.removeFirst()
        let text = String(text[stringIndex...])
        if let expressionToken = ExpressionToken(infix: expression, line: line) {
            if text == "" {
                return [expressionToken]
            }
            return [TextToken(value: text), expressionToken]
        }
        throw NutParserError(kind: .expressionError, line: line)
    }

    fileprivate func parseIf(text: String, line: Int) throws -> [NutTokenProtocol] {
        let expected = [
            "if <expression: Bool> {",
            "if let <variableName: Any> = <expression: Any?> {"
        ]

        let text = String(text[text.index(text.startIndex, offsetBy: 3)...])
        let chars = text.map({ String(describing: $0) })
        var prevChar = ""
        var inString = false
        var charIndex = 0
        guard text.first != "{" else {
            throw NutParserError(
                kind: .syntaxError(expected: expected, got: "if {"),
                line: line,
                description: "empty <expression>")
        }
        guard !text.hasPrefix("let {") else {
            throw NutParserError(
                kind: .syntaxError(expected: expected, got: "if let {"),
                line: line,
                description: "empty <expression>")
        }
        for char in chars {
            if char == "{" && !inString && prevChar == " " {
                let end = text.index(text.startIndex, offsetBy: charIndex)
                let condition = String(text[..<end].dropLast())

                let stringIndex = text.index(text.startIndex, offsetBy: charIndex + 1)
                let text = String(text[stringIndex...])
                guard condition != "" else {
                    throw NutParserError(
                        kind: .syntaxError(expected: expected, got: "if " + condition + " {"),
                        line: line,
                        description: "empty <expression>")
                }
                guard let token = IfToken(condition: condition, line: line) else {
                    throw NutParserError(
                        kind: .syntaxError(expected: expected, got: "if " + condition + " {"),
                        line: line)
                }
                if let variable = token.variable {
                    guard checkSimple(variable: variable) else {
                        throw NutParserError(
                            kind: .wrongSimpleVariable(
                                name: variable,
                                in: "if \(condition) {",
                                regex: simpleVariable.regex),
                            line: line)
                    }
                    guard checkSimple(variable: token.condition) else {
                        throw NutParserError(
                            kind: .wrongChainedVariable(
                                name: token.condition,
                                in: "if \(condition) {",
                                regex: chainedVariable.regex),
                            line: line)
                    }
                }
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
        throw NutParserError(
            kind: .syntaxError(expected: expected, got: "if " + text),
            line: line,
            description: "'{' not found")
    }
}

extension NutParser {
    private func checkSimple(variable: String) -> Bool {
        let regex = simpleVariable.value
        return regex.matches(variable)
    }

    private func checkChained(variable: String) -> Bool {
        let regex = chainedVariable.value
        return regex.matches(variable)
    }
}

// swiftlint:enable cyclomatic_complexity
// swiftlint:enable function_body_length
// swiftlint:enable file_length

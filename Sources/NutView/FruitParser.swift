//
//  FruitParser.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/12/17.
//
//

import SquirrelJSONEncoding

struct FruitParser {
    private let content: String

    init(content: String) {
        self.content = content
    }

    func tokenize() -> ViewToken {
        // swiftlint:disable:next force_try
        let json = try! JSON(json: content)!
        let name = json["fileName"].stringValue
        let body = parse(body: json["body"].arrayValue)
        let head: [NutHeadProtocol]
        if let headTokens = json["head"].array {
            head = parse(head: headTokens)
        } else {
            head = []
        }
        let layout = json["layout"]
        let layoutToken: LayoutToken?
        if layout["id"].stringValue == "layout" {
            let name = layout["name"].stringValue
            layoutToken = LayoutToken(name: name, line: layout["line"].intValue)
        } else {
            layoutToken = nil
        }

        return ViewToken(name: name, head: head, body: body, layout: layoutToken)
    }

    private func parse(head tokens: [JSON]) -> [NutHeadProtocol] {
        var head = [NutHeadProtocol]()
        tokens.forEach { (token) in
            switch token["id"].stringValue {
            case "title":
                let expr = parse(expression: token["expression"])
                head.append(TitleToken(expression: expr, line: token["line"].intValue))
            default:
                break
            }
        }
        return head
    }

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    private func parse(body tokens: [JSON]) -> [NutTokenProtocol] {
        var body = [NutTokenProtocol]()
        tokens.forEach({ (token) in
            switch token["id"].stringValue {
            case "text":
                body.append(TextToken(value: token["value"].stringValue))
            case "date":
                let date = parse(expression: token["date"])
                let format: ExpressionToken?
                if !token["format"].isNil {
                    format = parse(expression: token["format"])
                } else {
                    format = nil
                }
                body.append(DateToken(date: date, format: format, line: token["line"].intValue))
            case "for in Array":
                var forIn = ForInToken(
                    variable: token["variable"].stringValue,
                    array: token["array"].stringValue,
                    line: token["line"].intValue)

                forIn.setBody(body: parse(body: token["body"].arrayValue))
                body.append(forIn)
            case "for in Dictionary":
                var forIn = ForInToken(
                    key: token["key"].stringValue,
                    variable: token["variable"].stringValue,
                    array: token["array"].stringValue,
                    line: token["line"].intValue)

                forIn.setBody(body: parse(body: token["body"].arrayValue))
                body.append(forIn)
            case "expression":
                body.append(parse(expression: token))
            case "raw expression":
                body.append(parse(rawExpression: token))
            case "if":
                var ifToken = IfToken(
                    condition: token["condition"].stringValue,
                    line: token["line"].intValue)!

                ifToken.setThen(body: parse(body: token["then"].arrayValue))
                if let elseBlock = token["else"].array {
                    ifToken.setElse(body: parse(body: elseBlock))
                }
                body.append(ifToken)
            case "if let":
                var ifToken = IfToken(
                    variable: token["variable"].stringValue,
                    condition: token["condition"].stringValue,
                    line: token["line"].intValue)

                ifToken.setThen(body: parse(body: token["then"].arrayValue))
                if let elseBlock = token["else"].array {
                    ifToken.setElse(body: parse(body: elseBlock))
                }
                body.append(ifToken)
            case "view":
                body.append(InsertViewToken(line: token["line"].intValue))
            case "subview":
                body.append(SubviewToken(
                    name: token["name"].stringValue,
                    line: token["line"].intValue))
            default:
                break
            }
        })
        return body
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    private func parse(expression token: JSON) -> ExpressionToken {
        return ExpressionToken(infix: token["infix"].stringValue, line: token["line"].intValue)!
    }
    private func parse(rawExpression token: JSON) -> RawExpressionToken {
        return RawExpressionToken(infix: token["infix"].stringValue, line: token["line"].intValue)!
    }
}

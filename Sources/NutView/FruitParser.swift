//
//  FruitParser.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/12/17.
//
//

import SwiftyJSON

struct FruitParser {
    private let content: String
    
    init(content: String) {
        self.content = content
    }

    func tokenize() -> ViewToken {
        let data = content.data(using: .utf8, allowLossyConversion: false)!
        let json = JSON(data: data)
        let name = json["name"].stringValue
        let body = parse(body: json["body"].arrayValue)
        let head: [NutHeadProtocol]
        if let headTokens = json["head"].array {
            head = parse(head: headTokens)
        } else {
            head = []
        }
        
        return ViewToken(name: name, head: head, body: body)
    }

    private func parse(head tokens: [JSON]) -> [NutHeadProtocol] {
        var head = [NutHeadProtocol]()
        tokens.forEach { (token) in
            switch token["id"].stringValue {
            case "title":
                let expr = parse(expression: token["expression"])
                head.append(TitleToken(expression: expr, row: token["row"].intValue))
            default:
                break
            }
        }
        return head
    }

    private func parse(body tokens: [JSON]) -> [NutTokenProtocol] {
        var body = [NutTokenProtocol]()
        tokens.forEach({ (token) in
            switch token["id"].stringValue {
            case "text":
                body.append(TextToken(value: token["value"].stringValue))
            case "for in Array":
                var forIn = ForInToken(variable: token["variable"].stringValue, array: token["array"].stringValue, row: token["row"].intValue)
                forIn.setBody(body: parse(body: token["body"].arrayValue))
                body.append(forIn)
            case "for in Dictionary":
                var forIn = ForInToken(key: token["key"].stringValue, variable: token["variable"].stringValue, array: token["array"].stringValue, row: token["row"].intValue)
                forIn.setBody(body: parse(body: token["body"].arrayValue))
                body.append(forIn)
            case "expression":
                body.append(parse(expression: token))
            default:
                break
            }
        })
        return body
    }

    private func parse(expression token: JSON) -> ExpressionToken {
        return ExpressionToken(infix: token["infix"].stringValue, row: token["row"].intValue)!
    }
}

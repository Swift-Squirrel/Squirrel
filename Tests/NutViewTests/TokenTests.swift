//
//  TokenTests.swift
//  NutViewTests
//
//  Created by Filip Klembara on 9/5/17.
//

import XCTest
@testable import NutView
import SquirrelJSONEncoding

class TokenTests: XCTestCase {
    func testTextToken() {
        let token = TextToken(value: "value")

        XCTAssert(token.id == "text")
        XCTAssert(token.value == "value")

        let serialized = token.serialized
        XCTAssert(serialized["id"] as? String == "text")
        XCTAssert(serialized["value"] as? String == "value")
    }

    func testInsertView() {
        let token = InsertViewToken(line: 3)

        XCTAssert(token.id == "view")
        XCTAssert(token.line == 3)

        let serialized = token.serialized
        XCTAssert(serialized["id"] as? String == "view")
        XCTAssert(serialized["line"] as? Int == 3)


        let token1 = InsertViewToken(line: 2)

        XCTAssert(token1.id == "view")
        XCTAssert(token1.line == 2)

        let serialized1 = token1.serialized
        XCTAssert(serialized1["id"] as? String == "view")
        XCTAssert(serialized1["line"] as? Int == 2)
    }

    func testDate() {
        let token = DateToken(
            date: ExpressionToken(
                infix: "date",
                line: 5)!,
            format: ExpressionToken(
                infix: "\"MMM dd YY\"",
                line: 5)!, line: 5)

        XCTAssert(token.date.infix == "date")
        XCTAssert(token.format?.infix == "\"MMM dd YY\"")
        XCTAssert(token.id == "date")
        XCTAssert(token.line == 5)

        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id": "date","date": {"id": "expression","infix": "date",
            "line": 5},"format": {"id": "expression","infix": "\\"MMM dd YY\\"","line": 5},"line": 5}
            """)
        XCTAssert(serialized == expected, "serialized: \(String(describing: serialized))\nexpected: \(String(describing: expected))")

        let token1 = DateToken(
            date: ExpressionToken(infix: "date1", line: 1)!,
            line: 1)


        XCTAssert(token1.date.infix == "date1")
        XCTAssertNil(token1.format)
        XCTAssert(token1.id == "date")
        XCTAssert(token1.line == 1)

        let serialized1 = JSON(from: token1.serialized)
        let expected1 = try! JSON(string: """
            {"id": "date","date": {"id": "expression","infix": "date1","line": 1},"line": 1}
            """)

        XCTAssert(serialized1["id"] == expected1["id"])
        XCTAssert(serialized1["date"] == expected1["date"])
        XCTAssert(serialized1["date"]["id"] == expected1["date"]["id"])
        XCTAssert(serialized1["date"]["infix"] == expected1["date"]["infix"])
        XCTAssert(serialized1["date"]["line"] == expected1["date"]["line"])
        XCTAssert(serialized1["format"] == expected1["format"])
        XCTAssert(serialized1["line"] == expected1["line"])
        XCTAssert(serialized1 == expected1, "serialized: \(String(describing: serialized1))\nexpected: \(String(describing: expected1))")

        let token2 = DateToken(
            date: ExpressionToken(
                infix: "date2",
                line: 2)!,
            format: ExpressionToken(
                infix: "\"MMM YY\"",
                line: 2)!, line: 2)

        XCTAssert(token2.date.infix == "date2")
        XCTAssert(token2.format?.infix == "\"MMM YY\"")
        XCTAssert(token2.id == "date")
        XCTAssert(token2.line == 2)

        let serialized2 = JSON(from: token2.serialized)
        let expected2 = try! JSON(string: """
            {"id": "date","date": {"id": "expression","infix": "date2",
            "line": 2},"format": {"id": "expression","infix": "\\"MMM YY\\"","line": 2},"line": 2}
            """)
        XCTAssert(serialized2 == expected2, "serialized: \(String(describing: serialized2))\nexpected: \(String(describing: expected2))")

        let token3 = DateToken(
            date: ExpressionToken(infix: "date19", line: 10)!,
            line: 10)


        XCTAssert(token3.date.infix == "date19")
        XCTAssertNil(token3.format)
        XCTAssert(token3.id == "date")
        XCTAssert(token3.line == 10)

        let serialized3 = JSON(from: token3.serialized)
        let expected3 = try! JSON(string: """
            {"id": "date","date": {"id": "expression","infix": "date19","line": 10},"line": 10}
            """)
        XCTAssert(serialized3 == expected3, "serialized: \(String(describing: serialized3))\nexpected: \(String(describing: expected3))")
    }

    func testIf() {
        guard IfToken(condition: "b == true", line: 12) != nil else {
            XCTFail()
            return
        }
        var token = IfToken(condition: "b == true", line: 12)!

        XCTAssert(token.condition == "b == true")
        XCTAssert(token.elseBlock == nil)
        XCTAssert(token.id == "if")
        XCTAssert(token.variable == nil)
        XCTAssert(token.thenBlock.count == 0)
        XCTAssert(token.line == 12)

        var serialized = JSON(from: token.serialized)
        var expected = try! JSON(string: """
            {"id": "if","condition":"b == true","then":[],"line":12}
            """)

        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if","condition":"b == true","then":[],"line":12, "else": []}
            """)
        XCTAssertNotNil(token.elseBlock)
        XCTAssert(serialized == expected)

        // next
        guard IfToken(condition: "let b = true", line: 11) != nil else {
            XCTFail()
            return
        }
        token = IfToken(condition: "let b = true", line: 11)!

        XCTAssert(token.condition == "true")
        XCTAssert(token.elseBlock == nil)
        XCTAssert(token.id == "if let")
        XCTAssert(token.variable == "b")
        XCTAssert(token.thenBlock.count == 0)
        XCTAssert(token.line == 11)

        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if let","condition":"true","then":[],"line":11,"variable":"b"}
            """)

        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if let","condition":"true","then":[],"line":11,"variable":"b", "else": []}
            """)
        XCTAssertNotNil(token.elseBlock)
        XCTAssert(serialized == expected)

        // next
        token = IfToken(variable: "b", condition: "true", line: 15)

        XCTAssert(token.condition == "true")
        XCTAssert(token.elseBlock == nil)
        XCTAssert(token.id == "if let")
        XCTAssert(token.variable == "b")
        XCTAssert(token.thenBlock.count == 0)
        XCTAssert(token.line == 15)

        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if let","condition":"true","then":[],"line":15,"variable":"b"}
            """)

        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if let","condition":"true","then":[],"line":15,"variable":"b", "else": []}
            """)
        XCTAssertNotNil(token.elseBlock)
        XCTAssert(serialized == expected)
    }

    func testElseIf() {
        guard ElseIfToken(condition: "a == 21", line: 2) != nil else {
            XCTFail()
            return
        }
        var token = ElseIfToken(condition: "a == 21", line: 2)!

        XCTAssert(token.getCondition() == "a == 21")
        XCTAssert(token.id == "else if")
        XCTAssert(token.getElse() == nil)
        XCTAssert(token.getThen().count == 0)
        XCTAssert(token.line == 2)
        XCTAssert(token.variable == nil)

        var serialized = JSON(from: token.serialized)
        var expected = try! JSON(string: """
            {"id":"else if","condition":"a == 21","then":[],"line":2}
            """)
        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        XCTAssertNotNil(token.getElse())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"else if","condition":"a == 21","then":[],"line":2,"else":[]}
            """)
        XCTAssert(serialized == expected)

        guard ElseIfToken(condition: "let b = a", line: 21) != nil else {
            XCTFail()
            return
        }
        token = ElseIfToken(condition: "let b = a", line: 21)!

        XCTAssert(token.getCondition() == "a")
        XCTAssert(token.id == "else if let")
        XCTAssert(token.getElse() == nil)
        XCTAssert(token.getThen().count == 0)
        XCTAssert(token.line == 21)
        XCTAssert(token.variable == "b")

        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"else if let","condition":"a","then":[],"line":21,"variable":"b"}
            """)
        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        XCTAssertNotNil(token.getElse())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"else if let","condition":"a","then":[],"line":21,"variable":"b","else":[]}
            """)
        XCTAssert(serialized == expected)
    }

    func testLayout() {
        let token = LayoutToken(name: "Page", line: 4)

        XCTAssert(token.id == "layout")
        XCTAssert(token.name == "Page")
        XCTAssert(token.line == 4)

        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"layout","name":"Page","line":4}
            """)
        XCTAssert(serialized == expected)


        let token1 = LayoutToken(name: "Pages", line: 2)

        XCTAssert(token1.id == "layout")
        XCTAssert(token1.name == "Pages")
        XCTAssert(token1.line == 2)

        let serialized1 = JSON(from: token1.serialized)
        let expected1 = try! JSON(string: """
            {"id":"layout","name":"Pages","line":2}
            """)
        XCTAssert(serialized1 == expected1)
    }

    func testSubview() {
        var token = SubviewToken(name: "Nav", line: 1)

        XCTAssert(token.id == "subview")
        XCTAssert(token.name == "Nav")
        XCTAssert(token.line == 1)
        var serialized = JSON(from: token.serialized)
        var expected = try! JSON(string: """
            {"id":"subview","name":"Nav","line":1}
            """)
        XCTAssert(serialized == expected)

        // next
        token = SubviewToken(name: "Footer", line: 42)

        XCTAssert(token.id == "subview")
        XCTAssert(token.name == "Footer")
        XCTAssert(token.line == 42)
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"subview","name":"Footer","line":42}
            """)
        XCTAssert(serialized == expected)
    }

    func testTitle() {
        let token = TitleToken(expression: ExpressionToken(infix: "title", line: 14)!, line: 14)

        XCTAssert(token.expression.infix == "title")
        XCTAssert(token.id == "title")
        XCTAssert(token.line == 14)
        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"title","expression":{"id":"expression","infix":"title","line":14},"line":14}
            """)
        XCTAssert(serialized == expected)
    }

    func testForIn() {
        var token = ForInToken(key: "k", variable: "v", array: "dic", line: 52)

        XCTAssert(token.array == "dic")
        XCTAssert(token.body.count == 0)
        XCTAssert(token.id == "for in Dictionary")
        XCTAssert(token.key == "k")
        XCTAssert(token.line == 52)
        XCTAssert(token.variable == "v")

        var serialized = JSON(from: token.serialized)
        var expected = try! JSON(string: """
            {"id":"for in Dictionary","key":"k","variable":"v","body":[],"array":"dic","line":52}
            """)
        XCTAssert(serialized == expected)

        token = ForInToken(variable: "val", array: "arr", line: 214)

        XCTAssert(token.array == "arr")
        XCTAssert(token.body.count == 0)
        XCTAssert(token.id == "for in Array")
        XCTAssertNil(token.key)
        XCTAssert(token.line == 214)
        XCTAssert(token.variable == "val")

        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"for in Array","variable":"val","body":[],"array":"arr","line":214}
            """)
        XCTAssert(serialized == expected)
    }

    func testElse() {
        let token = ElseToken(line: 421)

        XCTAssert(token.getBody().count == 0)
        XCTAssert(token.id == "else")
        XCTAssert(token.line == 421)

        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"else","line":421}
            """)
        XCTAssert(serialized == expected)
    }

    func testEndBlock() {
        let token = EndBlockToken(line: 1241)

        XCTAssert(token.id == "}")
        XCTAssert(token.line == 1241)
        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"}","line":1241}
            """)
        XCTAssert(serialized == expected)
    }

    func testExpression() {
        guard let token = ExpressionToken(infix: "2 * ad", line: 31) else {
            XCTFail()
            return
        }

        XCTAssert(token.id == "expression")
        XCTAssert(token.infix == "2 * ad")
        XCTAssert(token.line == 31)
        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"expression","line":31,"infix":"2 * ad"}
            """)
        XCTAssert(serialized == expected)
    }

    func testRawExpression() {
        guard let token = RawExpressionToken(infix: "2 * ad", line: 31) else {
            XCTFail()
            return
        }

        XCTAssert(token.id == "raw expression")
        XCTAssert(token.infix == "2 * ad")
        XCTAssert(token.line == 31)
        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"raw expression","line":31,"infix":"2 * ad"}
            """)
        XCTAssert(serialized == expected)
    }

    static let allTests = [
        ("testTextToken", testTextToken),
        ("testInsertView", testInsertView),
        ("testDate", testDate),
        ("testIf", testIf),
        ("testElseIf", testElseIf),
        ("testLayout", testLayout),
        ("testSubview", testSubview),
        ("testTitle", testTitle),
        ("testForIn", testForIn),
        ("testElse", testElse),
        ("testEndBlock", testEndBlock),
        ("testExpression", testExpression),
        ("testRawExpression", testRawExpression)
    ]

}

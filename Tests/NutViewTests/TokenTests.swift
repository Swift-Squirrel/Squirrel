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
        let token = InsertViewToken(row: 3)

        XCTAssert(token.id == "view")
        XCTAssert(token.row == 3)

        let serialized = token.serialized
        XCTAssert(serialized["id"] as? String == "view")
        XCTAssert(serialized["row"] as? Int == 3)


        let token1 = InsertViewToken(row: 2)

        XCTAssert(token1.id == "view")
        XCTAssert(token1.row == 2)

        let serialized1 = token1.serialized
        XCTAssert(serialized1["id"] as? String == "view")
        XCTAssert(serialized1["row"] as? Int == 2)
    }

    func testDate() {
        let token = DateToken(
            date: ExpressionToken(
                infix: "date",
                row: 5)!,
            format: ExpressionToken(
                infix: "\"MMM dd YY\"",
                row: 5)!, row: 5)

        XCTAssert(token.date.infix == "date")
        XCTAssert(token.format.infix == "\"MMM dd YY\"")
        XCTAssert(token.id == "date")
        XCTAssert(token.row == 5)

        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id": "date","date": {"id": "expression","infix": "date",
            "row": 5},"format": {"id": "expression","infix": "\\"MMM dd YY\\"","row": 5},"row": 5}
            """)
        XCTAssert(serialized == expected, "serialized: \(String(describing: serialized))\nexpected: \(String(describing: expected))")

        let token1 = DateToken(
            date: ExpressionToken(infix: "date1", row: 1)!,
            row: 1)


        XCTAssert(token1.date.infix == "date1")
        XCTAssert(token1.format.infix == "\"MMM dd yyyy\"")
        XCTAssert(token1.id == "date")
        XCTAssert(token1.row == 1)

        let serialized1 = JSON(from: token1.serialized)
        let expected1 = try! JSON(string: """
            {"id": "date","date": {"id": "expression","infix": "date1","row": 1},
            "format": {"id": "expression","infix": "\\\"MMM dd yyyy\\\"","row": 1},"row": 1}
            """)

        XCTAssert(serialized1["id"] == expected1["id"])
        XCTAssert(serialized1["date"] == expected1["date"])
        XCTAssert(serialized1["date"]["id"] == expected1["date"]["id"])
        XCTAssert(serialized1["date"]["infix"] == expected1["date"]["infix"])
        XCTAssert(serialized1["date"]["row"] == expected1["date"]["row"])
        XCTAssert(serialized1["format"] == expected1["format"])
        XCTAssert(serialized1["row"] == expected1["row"])
        XCTAssert(serialized1 == expected1, "serialized: \(String(describing: serialized1))\nexpected: \(String(describing: expected1))")

        let token2 = DateToken(
            date: ExpressionToken(
                infix: "date2",
                row: 2)!,
            format: ExpressionToken(
                infix: "\"MMM YY\"",
                row: 2)!, row: 2)

        XCTAssert(token2.date.infix == "date2")
        XCTAssert(token2.format.infix == "\"MMM YY\"")
        XCTAssert(token2.id == "date")
        XCTAssert(token2.row == 2)

        let serialized2 = JSON(from: token2.serialized)
        let expected2 = try! JSON(string: """
            {"id": "date","date": {"id": "expression","infix": "date2",
            "row": 2},"format": {"id": "expression","infix": "\\"MMM YY\\"","row": 2},"row": 2}
            """)
        XCTAssert(serialized2 == expected2, "serialized: \(String(describing: serialized2))\nexpected: \(String(describing: expected2))")

        let token3 = DateToken(
            date: ExpressionToken(infix: "date19", row: 10)!,
            row: 10)


        XCTAssert(token3.date.infix == "date19")
        XCTAssert(token3.format.infix == "\"MMM dd yyyy\"")
        XCTAssert(token3.id == "date")
        XCTAssert(token3.row == 10)

        let serialized3 = JSON(from: token3.serialized)
        let expected3 = try! JSON(string: """
            {"id": "date","date": {"id": "expression","infix": "date19","row": 10},
            "format": {"id": "expression","infix": "\\"MMM dd yyyy\\"","row": 10},"row": 10}
            """)
        XCTAssert(serialized3 == expected3, "serialized: \(String(describing: serialized3))\nexpected: \(String(describing: expected3))")
    }

    func testIf() {
        guard IfToken(condition: "b == true", row: 12) != nil else {
            XCTFail()
            return
        }
        var token = IfToken(condition: "b == true", row: 12)!

        XCTAssert(token.condition == "b == true")
        XCTAssert(token.elseBlock == nil)
        XCTAssert(token.id == "if")
        XCTAssert(token.variable == nil)
        XCTAssert(token.thenBlock.count == 0)
        XCTAssert(token.row == 12)

        var serialized = JSON(from: token.serialized)
        var expected = try! JSON(string: """
            {"id": "if","condition":"b == true","then":[],"row":12}
            """)

        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if","condition":"b == true","then":[],"row":12, "else": []}
            """)
        XCTAssertNotNil(token.elseBlock)
        XCTAssert(serialized == expected)

        // next
        guard IfToken(condition: "let b = true ", row: 11) != nil else {
            XCTFail()
            return
        }
        token = IfToken(condition: "let b = true ", row: 11)!

        XCTAssert(token.condition == "true ")
        XCTAssert(token.elseBlock == nil)
        XCTAssert(token.id == "if let")
        XCTAssert(token.variable == "b")
        XCTAssert(token.thenBlock.count == 0)
        XCTAssert(token.row == 11)

        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if let","condition":"true ","then":[],"row":11,"variable":"b"}
            """)

        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if let","condition":"true ","then":[],"row":11,"variable":"b", "else": []}
            """)
        XCTAssertNotNil(token.elseBlock)
        XCTAssert(serialized == expected)

        // next
        token = IfToken(variable: "b", condition: "true", row: 15)

        XCTAssert(token.condition == "true")
        XCTAssert(token.elseBlock == nil)
        XCTAssert(token.id == "if let")
        XCTAssert(token.variable == "b")
        XCTAssert(token.thenBlock.count == 0)
        XCTAssert(token.row == 15)

        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if let","condition":"true","then":[],"row":15,"variable":"b"}
            """)

        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id": "if let","condition":"true","then":[],"row":15,"variable":"b", "else": []}
            """)
        XCTAssertNotNil(token.elseBlock)
        XCTAssert(serialized == expected)
    }

    func testElseIf() {
        guard ElseIfToken(condition: "a == 21 ", row: 2) != nil else {
            XCTFail()
            return
        }
        var token = ElseIfToken(condition: "a == 21 ", row: 2)!

        XCTAssert(token.getCondition() == "a == 21 ")
        XCTAssert(token.id == "else if")
        XCTAssert(token.getElse() == nil)
        XCTAssert(token.getThen().count == 0)
        XCTAssert(token.row == 2)
        XCTAssert(token.variable == nil)

        var serialized = JSON(from: token.serialized)
        var expected = try! JSON(string: """
            {"id":"else if","condition":"a == 21 ","then":[],"row":2}
            """)
        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        XCTAssertNotNil(token.getElse())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"else if","condition":"a == 21 ","then":[],"row":2,"else":[]}
            """)
        XCTAssert(serialized == expected)

        guard ElseIfToken(condition: "let b = a ", row: 21) != nil else {
            XCTFail()
            return
        }
        token = ElseIfToken(condition: "let b = a ", row: 21)!

        XCTAssert(token.getCondition() == "a ")
        XCTAssert(token.id == "else if let")
        XCTAssert(token.getElse() == nil)
        XCTAssert(token.getThen().count == 0)
        XCTAssert(token.row == 21)
        XCTAssert(token.variable == "b")

        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"else if let","condition":"a ","then":[],"row":21,"variable":"b"}
            """)
        XCTAssert(serialized == expected)

        token.setElse(body: [NutTokenProtocol]())
        XCTAssertNotNil(token.getElse())
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"else if let","condition":"a ","then":[],"row":21,"variable":"b","else":[]}
            """)
        XCTAssert(serialized == expected)

        // TODO
    }

    func testLayout() {
        let token = LayoutToken(name: "Page", row: 4)

        XCTAssert(token.id == "layout")
        XCTAssert(token.name == "Page")
        XCTAssert(token.row == 4)

        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"layout","name":"Page","row":4}
            """)
        XCTAssert(serialized == expected)


        let token1 = LayoutToken(name: "Pages", row: 2)

        XCTAssert(token1.id == "layout")
        XCTAssert(token1.name == "Pages")
        XCTAssert(token1.row == 2)

        let serialized1 = JSON(from: token1.serialized)
        let expected1 = try! JSON(string: """
            {"id":"layout","name":"Pages","row":2}
            """)
        XCTAssert(serialized1 == expected1)
    }

    func testSubview() {
        var token = SubviewToken(name: "Nav", row: 1)

        XCTAssert(token.id == "subview")
        XCTAssert(token.name == "Nav")
        XCTAssert(token.row == 1)
        var serialized = JSON(from: token.serialized)
        var expected = try! JSON(string: """
            {"id":"subview","name":"Nav","row":1}
            """)
        XCTAssert(serialized == expected)

        // next
        token = SubviewToken(name: "Footer", row: 42)

        XCTAssert(token.id == "subview")
        XCTAssert(token.name == "Footer")
        XCTAssert(token.row == 42)
        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"subview","name":"Footer","row":42}
            """)
        XCTAssert(serialized == expected)
    }

    func testTitle() {
        let token = TitleToken(expression: ExpressionToken(infix: "title", row: 14)!, row: 14)

        XCTAssert(token.expression.infix == "title")
        XCTAssert(token.id == "title")
        XCTAssert(token.row == 14)
        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"title","expression":{"id":"expression","infix":"title","row":14},"row":14}
            """)
        XCTAssert(serialized == expected)
    }

    func testForIn() {
        var token = ForInToken(key: "k", variable: "v", array: "dic", row: 52)

        XCTAssert(token.array == "dic")
        XCTAssert(token.body.count == 0)
        XCTAssert(token.id == "for in Dictionary")
        XCTAssert(token.key == "k")
        XCTAssert(token.row == 52)
        XCTAssert(token.variable == "v")

        var serialized = JSON(from: token.serialized)
        var expected = try! JSON(string: """
            {"id":"for in Dictionary","key":"k","variable":"v","body":[],"array":"dic","row":52}
            """)
        XCTAssert(serialized == expected)

        token = ForInToken(variable: "val", array: "arr", row: 214)

        XCTAssert(token.array == "arr")
        XCTAssert(token.body.count == 0)
        XCTAssert(token.id == "for in Array")
        XCTAssertNil(token.key)
        XCTAssert(token.row == 214)
        XCTAssert(token.variable == "val")

        serialized = JSON(from: token.serialized)
        expected = try! JSON(string: """
            {"id":"for in Array","variable":"val","body":[],"array":"arr","row":214}
            """)
        XCTAssert(serialized == expected)
    }

    func testElse() {
        let token = ElseToken(row: 421)

        XCTAssert(token.getBody().count == 0)
        XCTAssert(token.id == "else")
        XCTAssert(token.row == 421)

        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"else","row":421}
            """)
        XCTAssert(serialized == expected)
    }

    func testEndBlock() {
        let token = EndBlockToken(row: 1241)

        XCTAssert(token.id == "}")
        XCTAssert(token.row == 1241)
        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"}","row":1241}
            """)
        XCTAssert(serialized == expected)
    }

    func testExpression() {
        guard let token = ExpressionToken(infix: "2 * ad", row: 31) else {
            XCTFail()
            return
        }

        XCTAssert(token.id == "expression")
        XCTAssert(token.infix == "2 * ad")
        XCTAssert(token.row == 31)
        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"expression","row":31,"infix":"2 * ad"}
            """)
        XCTAssert(serialized == expected)
    }

    func testRawExpression() {
        guard let token = RawExpressionToken(infix: "2 * ad", row: 31) else {
            XCTFail()
            return
        }

        XCTAssert(token.id == "raw expression")
        XCTAssert(token.infix == "2 * ad")
        XCTAssert(token.row == 31)
        let serialized = JSON(from: token.serialized)
        let expected = try! JSON(string: """
            {"id":"raw expression","row":31,"infix":"2 * ad"}
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

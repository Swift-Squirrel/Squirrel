//
//  NutParserTests.swift
//  NutViewTests
//
//  Created by Filip Klembara on 9/6/17.
//

import XCTest
@testable import NutView
import SquirrelJSONEncoding

class NutParserTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleParse() {
        let parser = NutParser(content: """
            \\Title("Title of post")
            this is about \\(topic)
            """, name: "Views/Post.nut")

        XCTAssert(parser.jsonSerialized == "")

        guard let viewToken = try? parser.tokenize() else {
            XCTFail()
            return
        }

        XCTAssert(viewToken.body.count == 2, String(describing: viewToken.body))
        XCTAssert(viewToken.head.count == 1)
        XCTAssertNil(viewToken.layout)
        XCTAssert(viewToken.name == "Views/Post.nut")

        guard let serialized = try? JSON(json: parser.jsonSerialized) else {
            XCTFail()
            return
        }
        let expexted = try! JSON(json: """
            {"body":[{"id":"text","value":"\\nthis is about "},{"postfix":"[{\\"type\\":{\\"variable\\":\\"Variable\\"},\\"value\\":\\"topic\\"}]","infix":"topic","id":"expression","line":2}],"fileName":"Views\\/Post.nut","head":[{"id":"title","expression":{"postfix":"[{\\"type\\":{\\"string\\":\\"String\\"},\\"value\\":\\"Title of post\\"}]","infix":"\\"Title of post\\"","id":"expression","line":1},"line":1}]}
            """)

        XCTAssertEqual(serialized, expexted)
    }

    func testMediumParse() {
        let content = """
            <!-- Default.html -->
            <!DOCTYPE html>
            <html lang="en">
            <head>
                \\Subview("Page.Head")
            </head>
            <body>
                \\Subview("Page.Header.Jumbotron")
            <div class="container">
                <div class="line">
                    <div class="col-8 mx-auto">
                        \\View()
                    </div>
                </div>
            </div>
                \\Subview("Page.Footer")
            </body>
            </html>
            """
        let parser = NutParser(content: content, name: "Layouts/Default.nut")

        XCTAssert(parser.jsonSerialized == "")

        guard let viewToken = try? parser.tokenize() else {
            XCTFail()
            return
        }

        XCTAssert(viewToken.body.count == 9, String(describing: viewToken.body.count))
        XCTAssert(viewToken.head.count == 0)
        XCTAssertNil(viewToken.layout)
        XCTAssert(viewToken.name == "Layouts/Default.nut")

        guard let serialized = try? JSON(json: parser.jsonSerialized) else {
            XCTFail()
            return
        }
        let expexted = try! JSON(json: """
            {"body":[{"id":"text","value":"<!-- Default.html -->\\n<!DOCTYPE html>\\n<html lang=\\"en\\">\\n<head>\\n    "},{"id":"subview","name":"Subviews.Page.Head","line":5},{"id":"text","value":"\\n<\\/head>\\n<body>\\n    "},{"id":"subview","name":"Subviews.Page.Header.Jumbotron","line":8},{"id":"text","value":"\\n<div class=\\"container\\">\\n    <div class=\\"line\\">\\n        <div class=\\"col-8 mx-auto\\">\\n            "},{"id":"view","line":12},{"id":"text","value":"\\n        <\\/div>\\n    <\\/div>\\n<\\/div>\\n    "},{"id":"subview","name":"Subviews.Page.Footer","line":16},{"id":"text","value":"\\n<\\/body>\\n<\\/html>"}],"fileName":"Layouts\\/Default.nut"}
            """)

        XCTAssert(serialized == expexted, parser.jsonSerialized)
    }

    func testUnknownCommand() {
        let content = """
            dmth \\unknwon()
            """
        let parser = NutParser(content: content, name: "Subviews/Unknown.nut")
        guard let viewToken = try? parser.tokenize() else {
            XCTFail()
            return
        }
        XCTAssert(viewToken.body.count == 1)
        guard let serialized = try? JSON(json: parser.jsonSerialized) else {
            XCTFail()
            return
        }
        XCTAssert(serialized["body"][0]["id"].stringValue == "text")
        XCTAssert(serialized["body"][0]["value"].stringValue == "dmth \\unknwon()", "expecting 'dmth \\unknwon()' but got '\(serialized["body"][0]["value"].stringValue)'")

    }

    func testCommentedCommand() {
        let content = """
            dmth \\\\(smth)
            """
        let parser = NutParser(content: content, name: "Subviews/Unknown.nut")
        guard let viewToken = try? parser.tokenize() else {
            XCTFail()
            return
        }
        XCTAssert(viewToken.body.count == 1)
        guard let serialized = try? JSON(json: parser.jsonSerialized) else {
            XCTFail()
            return
        }
        XCTAssert(serialized["body"][0]["id"].stringValue == "text")
        XCTAssert(serialized["body"][0]["value"].stringValue == "dmth \\(smth)")
    }

    func testCommonCommands() {
        let content = """
            dasd alm ak po
            \\Date(date) oid
            \\if true {
                asd a \\Date(date1, format: "m" + years) asda
            \\}
            \\if 1 + 3 == 4 {
                true
            \\} else if true == true {
                \\(true)
            \\} else if let notNil = posts {
                doefja e
            \\}
            \\if let asd = Tom {
                dfe
            \\} else {
                ds
                \\Subview("Map")
            \\}

            \\for post in posts {
                \\RawValue(post.body)
            \\}
            \\for (key, value) in dictionary {
                \\(key + " " + value)
            \\}
            pdso a
            """
        let parser = NutParser(content: content, name: "Subviews/Smt.nut")

        XCTAssert(parser.jsonSerialized == "")

        guard let viewToken = try? parser.tokenize() else {
            XCTFail()
            return
        }

        XCTAssert(viewToken.body.count == 13, String(describing: viewToken.body.count))
        XCTAssert(viewToken.head.count == 0)
        XCTAssertNil(viewToken.layout)
        XCTAssert(viewToken.name == "Subviews/Smt.nut")

        guard let serialized = try? JSON(json: parser.jsonSerialized) else {
            XCTFail()
            return
        }

        let expexted = try! JSON(json: """
            {"body":[{"id":"text","value":"dasd alm ak po\\n"},{"id":"date","date":{"postfix":"[{\\"type\\":{\\"variable\\":\\"Variable\\"},\\"value\\":\\"date\\"}]","infix":"date","id":"expression","line":2},"line":2},{"id":"text","value":" oid\\n"},{"id":"if","condition":{"postfix":"[{\\"type\\":{\\"bool\\":\\"Bool\\"},\\"value\\":\\"true\\"}]","infix":"true","id":"raw expression","line":3},"then":[{"id":"text","value":"\\n    asd a "},{"date":{"postfix":"[{\\"type\\":{\\"variable\\":\\"Variable\\"},\\"value\\":\\"date1\\"}]","infix":"date1","id":"expression","line":4},"format":{"postfix":"[{\\"type\\":{\\"string\\":\\"String\\"},\\"value\\":\\"m\\"},{\\"type\\":{\\"variable\\":\\"Variable\\"},\\"value\\":\\"years\\"},{\\"type\\":{\\"operation\\":\\"+\\"},\\"value\\":\\"+\\"}]","infix":"\\"m\\" + years","id":"expression","line":4},"id":"date","line":4},{"id":"text","value":" asda\\n"}],"line":3},{"id":"text","value":"\\n"},{"else":[{"else":[{"variable":"notNil","id":"if let","condition":{"postfix":"[{\\"type\\":{\\"variable\\":\\"Variable\\"},\\"value\\":\\"posts\\"}]","infix":"posts","id":"raw expression","line":10},"then":[{"id":"text","value":"\\n    doefja e\\n"}],"line":10}],"id":"if","condition":{"postfix":"[{\\"type\\":{\\"bool\\":\\"Bool\\"},\\"value\\":\\"true\\"},{\\"type\\":{\\"bool\\":\\"Bool\\"},\\"value\\":\\"true\\"},{\\"type\\":{\\"operation\\":\\"==\\"},\\"value\\":\\"==\\"}]","infix":"true == true","id":"raw expression","line":8},"then":[{"id":"text","value":"\\n    "},{"postfix":"[{\\"type\\":{\\"bool\\":\\"Bool\\"},\\"value\\":\\"true\\"}]","infix":"true","id":"expression","line":9},{"id":"text","value":"\\n"}],"line":8}],"id":"if","condition":{"postfix":"[{\\"type\\":{\\"int\\":\\"Int\\"},\\"value\\":\\"1\\"},{\\"type\\":{\\"int\\":\\"Int\\"},\\"value\\":\\"3\\"},{\\"type\\":{\\"operation\\":\\"+\\"},\\"value\\":\\"+\\"},{\\"type\\":{\\"int\\":\\"Int\\"},\\"value\\":\\"4\\"},{\\"type\\":{\\"operation\\":\\"==\\"},\\"value\\":\\"==\\"}]","infix":"1 + 3 == 4","id":"raw expression","line":6},"then":[{"id":"text","value":"\\n    true\\n"}],"line":6},{"id":"text","value":"\\n"},{"variable":"asd","else":[{"id":"text","value":"    ds\\n    "},{"id":"subview","name":"Subviews.Map","line":17},{"id":"text","value":"\\n"}],"id":"if let","condition":{"postfix":"[{\\"type\\":{\\"variable\\":\\"Variable\\"},\\"value\\":\\"Tom\\"}]","infix":"Tom","id":"raw expression","line":13},"then":[{"id":"text","value":"\\n    dfe\\n"}],"line":13},{"id":"text","value":"\\n\\n"},{"variable":"post","id":"for in Array","array":"posts","body":[{"id":"text","value":"\\n    "},{"postfix":"[{\\"type\\":{\\"variable\\":\\"Variable\\"},\\"value\\":\\"post.body\\"}]","infix":"post.body","id":"raw expression","line":21},{"id":"text","value":"\\n"}],"line":20},{"id":"text","value":"\\n"},{"line":23,"variable":"value","id":"for in Dictionary","key":"key","array":"dictionary","body":[{"id":"text","value":"\\n    "},{"postfix":"[{\\"type\\":{\\"variable\\":\\"Variable\\"},\\"value\\":\\"key\\"},{\\"type\\":{\\"string\\":\\"String\\"},\\"value\\":\\" \\"},{\\"type\\":{\\"operation\\":\\"+\\"},\\"value\\":\\"+\\"},{\\"type\\":{\\"variable\\":\\"Variable\\"},\\"value\\":\\"value\\"},{\\"type\\":{\\"operation\\":\\"+\\"},\\"value\\":\\"+\\"}]","infix":"key + \\" \\" + value","id":"expression","line":24},{"id":"text","value":"\\n"}]},{"id":"text","value":"\\npdso a"}],"fileName":"Subviews\\/Smt.nut"}
            """)

        XCTAssertEqual(serialized, expexted)
    }

    func testViewCommands() {
        let content = """
            dasd alm ak po
            \\Layout("Default")
            \\Title("ds")
            """
        let parser = NutParser(content: content, name: "Views/Smt.nut")

        XCTAssert(parser.jsonSerialized == "")

        guard let viewToken = try? parser.tokenize() else {
            XCTFail()
            return
        }

        XCTAssert(viewToken.body.count == 2, String(describing: viewToken.body.count))
        XCTAssert(viewToken.head.count == 1)
        XCTAssertNotNil(viewToken.layout)
        XCTAssert(viewToken.name == "Views/Smt.nut")

        guard let serialized = try? JSON(json: parser.jsonSerialized) else {
            XCTFail()
            return
        }
        let expexted = try! JSON(json: """
            {"layout":{"id":"layout","name":"Layouts.Default","line":2},"body":[{"id":"text","value":"dasd alm ak po\\n"},{"id":"text","value":"\\n"}],"fileName":"Views\\/Smt.nut","head":[{"id":"title","expression":{"postfix":"[{\\"type\\":{\\"string\\":\\"String\\"},\\"value\\":\\"ds\\"}]","infix":"\\"ds\\"","id":"expression","line":3},"line":3}]}
            """)

        XCTAssert(serialized == expexted, parser.jsonSerialized)
    }

    func testLayoutCommands() {
        let content = """
            dasd alm ak po
            \\View()
                fa
            """
        let parser = NutParser(content: content, name: "Layouts/Smt.nut")

        XCTAssert(parser.jsonSerialized == "")

        guard let viewToken = try? parser.tokenize() else {
            XCTFail()
            return
        }

        XCTAssert(viewToken.body.count == 3, String(describing: viewToken.body.count))
        XCTAssert(viewToken.head.count == 0)
        XCTAssertNil(viewToken.layout)
        XCTAssert(viewToken.name == "Layouts/Smt.nut")

        guard let serialized = try? JSON(json: parser.jsonSerialized) else {
            XCTFail()
            return
        }
        let expexted = try! JSON(json: """
            {"body":[{"id":"text","value":"dasd alm ak po\\n"},{"id":"view","line":2},{"id":"text","value":"\\n    fa"}],"fileName":"Layouts\\/Smt.nut"}
            """)

        XCTAssert(serialized == expexted, parser.jsonSerialized)
    }

    static let allTests = [
        ("testSimpleParse", testSimpleParse),
        ("testMediumParse", testMediumParse),
        ("testUnknownCommand", testUnknownCommand),
        ("testCommentedCommand", testCommentedCommand),
        ("testCommonCommands", testCommonCommands),
        ("testViewCommands", testViewCommands),
        ("testLayoutCommands", testLayoutCommands),
    ]

}

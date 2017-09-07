//
//  FruitParserTests.swift
//  SquirrelTests
//
//  Created by Filip Klembara on 9/6/17.
//

import XCTest
@testable import NutView
class FruitParserTests: XCTestCase {

    func testSimpleLayout() {
        let content = """
            {"body":[{"id":"text","value":"<!-- Default.html -->\\n<!DOCTYPE html>\\n<html lang=\\"en\\">\\n<head>\\n    "},{"id":"subview","name":"Subviews.Page.Head","row":5},{"id":"text","value":"\\n<\\/head>\\n<body>\\n    "},{"id":"subview","name":"Subviews.Page.Header.Jumbotron","row":8},{"id":"text","value":"\\n<div class=\\"container\\">\\n    <div class=\\"row\\">\\n        <div class=\\"col-8 mx-auto\\">\\n            "},{"id":"view","row":12},{"id":"text","value":"\\n        <\\/div>\\n    <\\/div>\\n<\\/div>\\n    "},{"id":"subview","name":"Subviews.Page.Footer","row":16},{"id":"text","value":"\\n<\\/body>\\n<\\/html>"}],"fileName":"Layouts\\/Default.nut"}
            """
        let parser = FruitParser(content: content)
        let viewToken = parser.tokenize()
        XCTAssertEqual(viewToken.body.count, 9)
        XCTAssertEqual(viewToken.head.count, 0)
        XCTAssertNil(viewToken.layout)
        XCTAssertEqual(viewToken.name, "Layouts/Default.nut")
    }

    func testSimpleView() {
        let content = """
            {"layout":{"id":"layout","name":"Layouts.Default","row":3},"body":[{"id":"text","value":"<!-- Posts.html -->\\n\\n"},{"id":"text","value":"\\n\\n"},{"id":"text","value":"\\n\\n<div class=\\"row mb-3\\">\\n<div class=\\"col\\">\\n<h1>Posts<\\/h1>\\n<\\/div>\\n<\\/div>\\n\\n"},{"variable":"post","row":13,"id":"for in Array","array":"posts","body":[{"id":"text","value":"\\n<div class=\\"row\\">\\n<div class=\\"col\\">\\n<article class=\\"row border rounded mb-3 p-1\\" style=\\"max-height: 400px\\">\\n<div class=\\"col-6 mx-auto col-md-3 align-self-center\\">\\n<img class=\\"rounded img-fluid\\" src=\\"Images\\/Logos\\/squirrel.svg\\">\\n<\\/div>\\n<div class=\\"col-12 col-md-9\\">\\n<div class=\\"row\\">\\n<div class=\\"col\\">\\n<h1><a class=\\"text-dark\\" href=\\"\\/posts\\/"},{"id":"expression","infix":"post.id","row":23},{"id":"text","value":"\\">"},{"id":"expression","infix":"post.title","row":23},{"id":"text","value":"<\\/a><\\/h1>\\n<\\/div>\\n<\\/div>\\n<div class=\\"row\\">\\n<div class=\\"col text-truncate\\">\\n"},{"id":"expression","infix":"post.brief","row":28},{"id":"text","value":"\\n<\\/div>\\n<\\/div>\\n<div class=\\"row text-muted\\">\\n<div class=\\"col\\">\\n"},{"id":"expression","infix":"post.likes","row":33},{"id":"text","value":" <span class=\\"ml-1 mr-2 text-success oi oi-thumb-up\\"><\\/span>\\n"},{"id":"expression","infix":"post.comments.count","row":34},{"id":"text","value":" <span class=\\"ml-1 mr-2 oi oi-chat\\"><\\/span>\\n"},{"id":"expression","infix":"post.dislikes","row":35},{"id":"text","value":" <span class=\\"ml-1 mr-2 text-danger oi oi-thumb-down\\"><\\/span>\\n<\\/div>\\n<div class=\\"col text-right  align-self-end\\">\\n"},{"date":{"id":"expression","infix":"post.created","row":38},"format":{"id":"expression","infix":"\\"MMM dd yyyy\\"","row":38},"row":38,"id":"date"},{"id":"text","value":"\\n<\\/div>\\n<\\/div>\\n<\\/div>\\n<\\/article>\\n<\\/div>\\n<\\/div>\\n"}]},{"id":"text","value":"\\n"}],"fileName":"Views\\/Posts.nut","head":[{"id":"title","expression":{"id":"expression","infix":"\\"Posts\\"","row":5},"row":5}]}
            """
        let parser = FruitParser(content: content)
        let viewToken = parser.tokenize()
        XCTAssertEqual(viewToken.body.count, 5)
        XCTAssertEqual(viewToken.head.count, 1)
        XCTAssertNotNil(viewToken.layout)
        XCTAssertEqual(viewToken.name, "Views/Posts.nut")
    }
    
    static let allTests = [
        ("testSimpleLayout", testSimpleLayout),
        ("testSimpleView", testSimpleView)
    ]

}

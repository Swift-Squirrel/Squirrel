//
//  FruitParserTests.swift
//  SquirrelTests
//
//  Created by Filip Klembara on 9/6/17.
//

import XCTest
import SquirrelJSONEncoding
@testable import NutView
class FruitParserTests: XCTestCase {

    func testSimpleLayout() {
        let content = """
            {"body":[{"id":"text","value":"<!-- Default.html -->\\n<!DOCTYPE html>\\n<html lang=\\"en\\">\\n<head>\\n    "},{"id":"subview","name":"Subviews.Page.Head","line":5},{"id":"text","value":"\\n<\\/head>\\n<body>\\n    "},{"id":"subview","name":"Subviews.Page.Header.Jumbotron","line":8},{"id":"text","value":"\\n<div class=\\"container\\">\\n    <div class=\\"line\\">\\n        <div class=\\"col-8 mx-auto\\">\\n            "},{"id":"view","line":12},{"id":"text","value":"\\n        <\\/div>\\n    <\\/div>\\n<\\/div>\\n    "},{"id":"subview","name":"Subviews.Page.Footer","line":16},{"id":"text","value":"\\n<\\/body>\\n<\\/html>"}],"fileName":"Layouts\\/Default.nut"}
            """
        let parser = FruitParser(content: content)
        let viewToken = parser.tokenize()
        XCTAssertEqual(viewToken.body.count, 9)
        XCTAssertEqual(viewToken.head.count, 0)
        XCTAssertNil(viewToken.layout)
        XCTAssertEqual(viewToken.name, "Layouts/Default.nut")
        let jsonExp = try! JSON(json: content)
        guard let vtData = viewToken.encode() else {
            XCTFail()
            return
        }
        guard let jsonRes = try? JSON(json: vtData) else {
            XCTFail()
            return
        }
        XCTAssertEqual(jsonExp, jsonRes)
    }

    func testSimpleView() {
        let content = """
            {"fileName":"Views\\/Posts.nut","layout":{"id":"layout","name":"Layouts.Default","line":3},"body":[{"id":"text","value":"<!-- Posts.html -->\\n\\n"},{"id":"text","value":"\\n\\n"},{"id":"text","value":"\\n\\n<div class=\\"row mb-3\\">\\n    <div class=\\"col\\">\\n        <h1>Posts<\\/h1>\\n    <\\/div>\\n<\\/div>\\n\\n"},{"variable":"post","id":"for in Array","array":"posts","body":[{"id":"text","value":"\\n<div class=\\"row\\">\\n<div class=\\"col\\">\\n    <article class=\\"row border rounded mb-3 p-1\\" style=\\"max-height: 400px\\">\\n        <div class=\\"col-6 mx-auto col-md-3 align-self-center\\">\\n            <img class=\\"rounded img-fluid\\" src=\\"\\/Images\\/Logos\\/squirrel.svg\\">\\n        <\\/div>\\n        <div class=\\"col-12 col-md-9\\">\\n            <div class=\\"row\\">\\n                <div class=\\"col\\">\\n                    <h1><a class=\\"text-dark\\" href=\\"\\/posts\\/"},{"postfix":[{"type":{"variable":"Variable"},"value":"post.id"}],"infix":"post.id","id":"raw expression","line":23},{"id":"text","value":"\\">"},{"postfix":[{"type":{"variable":"Variable"},"value":"post.title"}],"infix":"post.title","id":"raw expression","line":23},{"id":"text","value":"<\\/a><\\/h1>\\n                <\\/div>\\n            <\\/div>\\n            <div class=\\"row\\">\\n                <div class=\\"col text-truncate\\">\\n                    "},{"postfix":[{"type":{"variable":"Variable"},"value":"post.brief"}],"infix":"post.brief","id":"raw expression","line":28},{"id":"text","value":"\\n                <\\/div>\\n            <\\/div>\\n            <div class=\\"row text-muted\\">\\n                <div class=\\"col\\">\\n                    "},{"postfix":[{"type":{"variable":"Variable"},"value":"post.likes"}],"infix":"post.likes","id":"raw expression","line":33},{"id":"text","value":" <span class=\\"ml-1 mr-2 text-success oi oi-thumb-up\\"><\\/span>\\n                    "},{"postfix":[{"type":{"variable":"Variable"},"value":"post.comments.count"}],"infix":"post.comments.count","id":"raw expression","line":34},{"id":"text","value":" <span class=\\"ml-1 mr-2 oi oi-chat\\"><\\/span>\\n                    "},{"postfix":[{"type":{"variable":"Variable"},"value":"post.dislikes"}],"infix":"post.dislikes","id":"raw expression","line":35},{"id":"text","value":" <span class=\\"ml-1 mr-2 text-danger oi oi-thumb-down\\"><\\/span>\\n                <\\/div>\\n                <div class=\\"col text-right  align-self-end\\">\\n                    By <a class=\\"disabled\\" href=\\"\\/users\\/"},{"postfix":[{"type":{"variable":"Variable"},"value":"post.creator"}],"infix":"post.creator","id":"raw expression","line":38},{"id":"text","value":"\\">"},{"postfix":[{"type":{"variable":"Variable"},"value":"post.creator"}],"infix":"post.creator","id":"raw expression","line":38},{"id":"text","value":"<\\/a><br>\\n                    "},{"id":"date","date":{"postfix":[{"type":{"variable":"Variable"},"value":"post.created"}],"infix":"post.created","id":"raw expression","line":39},"line":39},{"id":"text","value":"\\n                <\\/div>\\n            <\\/div>\\n        <\\/div>\\n    <\\/article>\\n    <\\/div>\\n<\\/div>\\n"}],"line":13},{"id":"text","value":""}],"head":[{"id":"title","expression":{"postfix":[{"type":{"string":"String"},"value":"Posts"}],"infix":"\\"Posts\\"","id":"raw expression","line":5},"line":5}]}
            """

        let parser = FruitParser(content: content)
        let viewToken = parser.tokenize()
        XCTAssertEqual(viewToken.body.count, 5)
        XCTAssertEqual(viewToken.head.count, 1)
        XCTAssertNotNil(viewToken.layout)
        XCTAssertEqual(viewToken.name, "Views/Posts.nut")
        let jsonExp = try! JSON(json: content)
        guard let vtData = viewToken.encode() else {
            XCTFail()
            return
        }
        XCTAssertNoThrow(try JSON(json: vtData))
        guard let jsonRes = try? JSON(json: vtData) else {
            XCTFail()
            return
        }
        XCTAssertEqual(jsonExp, jsonRes)
    }
    
    static let allTests = [
        ("testSimpleLayout", testSimpleLayout),
        ("testSimpleView", testSimpleView)
    ]

}

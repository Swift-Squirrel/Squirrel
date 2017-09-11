//
//  InterpreterTests.swift
//  NutViewIntegrationTests
//
//  Created by Filip Klembara on 9/8/17.
//

import XCTest
import PathKit
import Foundation
@testable import NutView

class InterpreterTests: XCTestCase {

    private var expectedHTMLs = Path()

    private let created: Date = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy"
        let date = dateFormatter.date(from: "Sep 08 2017")!
        return date
    }()

    override func setUp() {
        super.setUp()
        #if Xcode
            NutConfig.fruits = Path() + "Resources/Fruits"
            NutConfig.nuts = Path() + "Resources/Nuts"
            expectedHTMLs = Path() + "Resources/ExpectedHTMLs"
            if !NutConfig.nuts.exists {
                XCTFail("When using xcode testing you should copy Tests/NutViewIntegrationTests/Resources to /tmp/Resources")
            }
        #else
            NutConfig.fruits = Path() + "Tests/NutViewIntegrationTests/Resources/Fruits"
            NutConfig.nuts = Path() + "Tests/NutViewIntegrationTests/Resources/Nuts"
            expectedHTMLs = Path() + "Tests/NutViewIntegrationTests/Resources/ExpectedHTMLs"
        #endif
//        try? NutConfig.fruits.mkpath()
    }

    override func tearDown() {
        super.tearDown()
//        NutConfig.clearFruits(removeRootDirectory: true)
    }

    func testPosts() {
        let data: [String: Any] = [
            "posts": [
                [
                    "id": "59984722610934e182846e7b",
                    "title": "Dogs",
                    "brief": "About dogs.",
                    "likes": 1,
                    "comments": [String](),
                    "dislikes": 0,
                    "created": Double(created.timeIntervalSince1970)
                ], [
                    "id": "59984722610934e182846e7c",
                    "title": "Cats",
                    "brief": "About cats.",
                    "likes": 2,
                    "comments": [String](),
                    "dislikes": 1,
                    "created": Double(created.timeIntervalSince1970)
                ]
            ],
        ]
        let name = "Posts"
        let interpreter = NutInterpreter(view: name, with: data)
        XCTAssertNoThrow(try interpreter.resolve())

        guard let interpreted = try? interpreter.resolve() else {
            XCTFail()
            return
        }
        let fileName = "\(name).html"
        guard let cnt: String = try? (expectedHTMLs + fileName).read() else {
            XCTFail("Can not read \(fileName)")
            return
        }
        XCTAssertEqual(interpreted, cnt)
    }

    func testPost() {
        let data: [String: Any] = [
            "id": "59984722610934e182846e7b",
            "title": "Dogs",
            "brief": "About dogs.",
            "likes": 1,
            "body": "Dogs are not cats!",
            "comments": [String](),
            "dislikes": 0,
            "created": Double(created.timeIntervalSince1970)
        ]
        let name = "Post"
        let interpreter = NutInterpreter(view: name, with: data)
        XCTAssertNoThrow(try interpreter.resolve())

        guard let interpreted = try? interpreter.resolve() else {
            XCTFail()
            return
        }

        let fileName = "\(name).html"
        guard let cnt: String = try? (expectedHTMLs + fileName).read() else {
            XCTFail("Can not read \(fileName)")
            return
        }
        XCTAssertEqual(interpreted, cnt)
    }

    func testMissingVariable() {
        let data: [String: Any] = [:]
        let name = "Posts"
        let interpreter = NutInterpreter(view: name, with: data)
        var expected = NutParserError(kind: .missingValue(for: "posts"), line: 13)
        expected.name = "Views/Posts.nut"
        XCTAssertTrue(checkError(for: interpreter, expect: expected), "Missing value for 'posts'")
    }

    func testWrongTypeVariable() {
        let data: [String: Any] = [
            "posts": [
                [
                    "id": "59984722610934e182846e7b",
                    "title": "Dogs",
                    "brief": "About dogs.",
                    "likes": 1,
                    "comments": [String](),
                    "dislikes": 0,
                    "created": "asd"
                ], [
                    "id": "59984722610934e182846e7c",
                    "title": "Cats",
                    "brief": "About cats.",
                    "likes": 2,
                    "comments": [String](),
                    "dislikes": 1,
                    "created": Double(created.timeIntervalSince1970)
                ]
            ],
            ]
        let name = "Posts"
        let interpreter = NutInterpreter(view: name, with: data)
        var expected = NutParserError(kind: .wrongValue(for: "Date(_:format:)", expected: "Double", got: "asd"), line: 38)
        expected.name = "Views/Posts.nut"
        XCTAssertTrue(checkError(for: interpreter, expect: expected), "String in Date")
    }

    private func checkError(for interpreter: NutInterpreterProtocol, expect: NutParserError) -> Bool {
        do {
            let cnt = try interpreter.resolve()
            XCTFail(cnt)
        } catch let error as NutParserError {
            XCTAssertEqual(expect.description, error.description)
            if expect.description == error.description {
                return true
            }
        } catch let error {
            XCTFail(String(describing: error))
        }
        return false
    }

    static let allTests = [
        ("testPosts", testPosts),
        ("testPost", testPost),
        ("testMissingVariable", testMissingVariable),
        ("testWrongTypeVariable", testWrongTypeVariable)
    ]
}

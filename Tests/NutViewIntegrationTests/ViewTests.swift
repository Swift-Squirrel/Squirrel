//
//  ViewTests.swift
//  NutViewIntegrationTests
//
//  Created by Filip Klembara on 9/8/17.
//

import XCTest
import SquirrelConnector
import Foundation
import PathKit
@testable import NutView

struct Post: Model {
    var id: ObjectId? = nil
    let title: String
    let brief: String
    let body: String
    let likes: Int
    let comments = [String]()
    let dislikes: Int
    let created: Date

    init(id: ObjectId, title: String, body: String, brief: String, likes: Int = 0, dislikes: Int = 0) {
        self.id = id
        self.title = title
        self.body = body
        self.brief = brief
        self.likes = likes
        self.dislikes = dislikes
        created = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd yyyy"
            let date = dateFormatter.date(from: "Sep 08 2017")!
            return date
        }()
    }
}

class ViewTests: XCTestCase {

    private var expectedHTMLs = Path()

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
        let data = [
            Post(id: try! ObjectId("59984722610934e182846e7b"),
                 title: "Dogs", body: "Dogs are not cats!",
                 brief: "About dogs.", likes: 1, dislikes: 0),
            Post(id: try! ObjectId("59984722610934e182846e7c"),
                 title: "Cats", body: "Cats are not dogs!",
                 brief: "About cats.", likes: 2, dislikes: 1)
        ]
        let name = "Posts"
        XCTAssertNoThrow(try View(name: name, with: data))
        guard let view = try? View(name: name, with: data) else {
            XCTFail()
            return
        }

        XCTAssertNoThrow(try view.getContent())

        guard let interpreted = try? view.getContent() else {
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
        let data = Post(id: try! ObjectId("59984722610934e182846e7b"),
                        title: "Dogs", body: "Dogs are not cats!",
                        brief: "About dogs.", likes: 1, dislikes: 0)

        let name = "Post"
        XCTAssertNoThrow(try View(name: name, with: data))
        guard let view = try? View(name: name, with: data) else {
            XCTFail()
            return
        }

        XCTAssertNoThrow(try view.getContent())

        guard let interpreted = try? view.getContent() else {
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
        let name = "Posts"
        let view = View(name: name)

        var expected = NutParserError(kind: .missingValue(for: "posts"), row: 13)
        expected.name = "Views/Posts.nut"
        XCTAssertTrue(checkError(for: view, expect: expected), "Missing value for 'posts'")
    }

    private func checkError(for view: ViewProtocol, expect: NutParserError) -> Bool {
        do {
            let cnt = try view.getContent()
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
        ("testMissingVariable", testMissingVariable)
    ]
}

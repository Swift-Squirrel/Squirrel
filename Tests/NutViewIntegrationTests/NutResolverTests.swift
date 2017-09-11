//
//  NutResolverTests.swift
//  NutViewIntegrationTests
//
//  Created by Filip Klembara on 9/8/17.
//

import XCTest
import PathKit
@testable import NutView

class NutResolverTests: XCTestCase {

    override func setUp() {
        super.setUp()
        #if Xcode
            NutConfig.fruits = Path() + "Resources/Fruits"
            NutConfig.nuts = Path() + "Resources/Nuts"
            if !NutConfig.nuts.exists {
                XCTFail("When using xcode testing you should copy Tests/NutViewIntegrationTests/Resources to /tmp/Resources")
            }
        #else
            NutConfig.fruits = Path() + "Tests/NutViewIntegrationTests/Resources/Fruits"
            NutConfig.nuts = Path() + "Tests/NutViewIntegrationTests/Resources/Nuts"
        #endif
//        try? NutConfig.fruits.mkpath()
    }
    
    override func tearDown() {
        super.tearDown()
//        NutConfig.clearFruits(removeRootDirectory: true)
    }

    func testSuccessResolingPosts() {
        let resolver: NutResolverProtocol.Type = NutResolver.self

        XCTAssertNoThrow(try resolver.viewToken(for: "Views.Posts"))
        guard let viewToken = try? resolver.viewToken(for: "Views.Posts") else {
            XCTFail("Views.Posts threw error")
            return
        }

        XCTAssertEqual(viewToken.body.count, 5)
        XCTAssertEqual(viewToken.head.count, 1)
        XCTAssertEqual(viewToken.layout?.name, "Layouts.Default")
    }

    func testSuccessResolingPost() {
        let resolver: NutResolverProtocol.Type = NutResolver.self

        XCTAssertNoThrow(try resolver.viewToken(for: "Views.Post"))
        guard let viewToken = try? resolver.viewToken(for: "Views.Post") else {
            XCTFail("Views.Post threw error")
            return
        }

        XCTAssertEqual(viewToken.body.count, 7)
        XCTAssertEqual(viewToken.head.count, 1)
        XCTAssertEqual(viewToken.layout?.name, "Layouts.Default")
    }

    func testSuccessResolingDefaultLayout() {
        let resolver: NutResolverProtocol.Type = NutResolver.self
        let name = "Layouts.Default"

        XCTAssertNoThrow(try resolver.viewToken(for: name))
        guard let viewToken = try? resolver.viewToken(for: name) else {
            XCTFail("\(name) threw error")
            return
        }

        XCTAssertEqual(viewToken.body.count, 9)
        XCTAssertEqual(viewToken.head.count, 0)
        XCTAssertNil(viewToken.layout)
    }

    func testSuccessResolingHeadSubview() {
        let resolver: NutResolverProtocol.Type = NutResolver.self
        let name = "Subviews.Page.Head"

        XCTAssertNoThrow(try resolver.viewToken(for: name))
        guard let viewToken = try? resolver.viewToken(for: name) else {
            XCTFail("\(name) threw error")
            return
        }

        XCTAssertEqual(viewToken.body.count, 1)
        XCTAssertEqual(viewToken.head.count, 0)
        XCTAssertNil(viewToken.layout)
    }

    func testNotExists() {
        let resolver: NutResolverProtocol.Type = NutResolver.self
        let name = "Subviews.Page.Heada"

        XCTAssertThrowsError(try resolver.viewToken(for: name))
        do {
            _ = try resolver.viewToken(for: name)
            XCTFail()
        } catch let error as NutError {
            let expected = NutError(kind: .notExists(name: "Subviews/Page/Heada.nut"))
            XCTAssertEqual(error.description, expected.description)
        } catch let error {
            XCTFail(String(describing: error))
        }
    }

    static let allTests = [
        ("testSuccessResolingPosts", testSuccessResolingPosts),
        ("testSuccessResolingPost", testSuccessResolingPost),
        ("testSuccessResolingDefaultLayout", testSuccessResolingDefaultLayout),
        ("testSuccessResolingHeadSubview", testSuccessResolingHeadSubview),
        ("testNotExists", testNotExists)
    ]
}

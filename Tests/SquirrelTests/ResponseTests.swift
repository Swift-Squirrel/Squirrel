//
//  ResponseTests.swift
//  SquirrelTests
//
//  Created by Filip Klembara on 9/11/17.
//

import XCTest
@testable import Squirrel

class ResponseTests: XCTestCase {

    func testInits() {
        XCTAssertNoThrow(try Response(html: "SMTH"))
        XCTAssertNoThrow(try Response(json: "{\"a\":1}"))
    }

    static let allTests = [
        ("testInits", testInits)
    ]

}

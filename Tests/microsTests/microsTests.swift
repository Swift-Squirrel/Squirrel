import XCTest
@testable import micros

class microsTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(micros().text, "Hello, World!")
    }
    
    func testServer() {
        XCTAssertNotNil(Server(port: 12) as? Server)
    }


    static var allTests = [
        ("testExample", testExample), ("testServer", testServer)
    ]
}
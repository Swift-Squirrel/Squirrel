import XCTest
@testable import micros

class microsTests: XCTestCase {
    
    func testServer() {
        XCTAssertNotNil(Server(port: 12) as? Server)
    }


    static var allTests = [
        ("testServer", testServer)
    ]
}

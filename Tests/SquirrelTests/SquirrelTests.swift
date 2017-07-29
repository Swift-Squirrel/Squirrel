import XCTest
@testable import Squirrel

class SquirrelTests: XCTestCase {
    
    func testServer() {
        let server: Any = Server(port: 8080, serverRoot: "/Users/Navel/Leo/Skola/3BIT/IBT/Micros")
        XCTAssertTrue(server is Server)
    }

    static var allTests = [
        ("testServer", testServer)
    ]
}

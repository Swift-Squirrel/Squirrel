import XCTest
@testable import Micros

class MicrosTests: XCTestCase {
    
    func testServer() {
        let server: Any = Server(port: 8080, serverRoot: "/Users/Navel/Leo/Skola/3BIT/IBT/Micros")
        XCTAssertTrue(server is Server)
    }

    static var allTests = [
        ("testServer", testServer)
    ]
}

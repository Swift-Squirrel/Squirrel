import XCTest
@testable import Micros

class MicrosTests: XCTestCase {
    
    func testServer() {
        let server: Any = Server(port: 8080, serverRoot: "/Users/Navel/Leo/Skola/3BIT/IBT/Micros")
        XCTAssertTrue(server is Server)
//        XCTAssertNotNil(Server(port: 12) as? Server)
    }

    func testJSONCoding() {
        /*
            public struct JSONCoding {

            internal static func encodeDataJSON<T>(object: T) throws -> Data

            internal static func isValid(json: String) -> Bool

            internal static func encodeJSON<T>(object: T) throws -> String
            }
         */

        
    }


    static var allTests = [
        ("testServer", testServer)
    ]
}

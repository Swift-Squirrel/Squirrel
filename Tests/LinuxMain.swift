import XCTest
@testable import SquirrelTests

XCTMain([
    testCase(RouteThreeTests.allTests),
    testCase(JSONCodingTests.allTests)
])

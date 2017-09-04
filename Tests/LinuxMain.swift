import XCTest
@testable import SquirrelTests

XCTMain([
    testCase(SquirrelTests.allTests),
    testCase(RouteThreeTests.allTests),
    testCase(JSONCodingTests.allTests)
])

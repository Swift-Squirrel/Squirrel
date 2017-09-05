import XCTest
@testable import SquirrelTests
@testable import JSONCodingTests

XCTMain([
    testCase(RouteThreeTests.allTests),
    testCase(JSONCodingTests.allTests),
    testCase(JSONTests.allTests)
])

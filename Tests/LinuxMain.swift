import XCTest
@testable import SquirrelTests

XCTMain([
    testCase(RouteThreeTests.allTests),
    testCase(RequestTests.allTests),
    testCase(SessionTests.allTests),
    testCase(ResponseTests.allTests),
])

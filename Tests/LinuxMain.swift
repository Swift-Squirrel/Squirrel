import XCTest
@testable import SquirrelTests
@testable import JSONCodingTests
@testable import NutViewTests
@testable import NutViewIntegrationTests

XCTMain([
    testCase(RouteThreeTests.allTests),
    testCase(RequestTests.allTests),
    testCase(SessionTests.allTests),
    testCase(ResponseTests.allTests),
    testCase(NutResolverTests.allTests),
    testCase(InterpreterTests.allTests),
    testCase(ViewTests.allTests)
])

import XCTest
@testable import SquirrelTests
@testable import JSONCodingTests
@testable import NutViewTests

XCTMain([
    testCase(RouteThreeTests.allTests),
    testCase(NutViewTests.allTests),
    testCase(NutParserTests.allTests),
    testCase(FruitParserTests.allTests),
    testCase(JSONCodingTests.allTests),
    testCase(JSONTests.allTests)
])

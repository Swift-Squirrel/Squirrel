//
//  JSONTests.swift
//  SquirrelTests
//
//  Created by Filip Klembara on 9/5/17.
//

import XCTest
import Test
@testable import SquirrelJSONEncoding

class JSONTests: XCTestCase {

    private struct JSONS {
        static let simple = "{\"id\":1,\"name\":\"Thom\",\"age\":21}"
        static let oneSubstruct = "{\"a\":3,\"c\":{\"a\":\"SubStruct\",\"double\":3.1,\"bool\":1}}"
        static let medium = """
                    {\"books\":{\"book\":[{\"title\":\"CPP\",\"author\":\"Milton\",\"year\":\"2008\",
                    \"price\":\"456.00\"},{\"title\":\"JAVA\",\"author\":\"Gilson\",\"year\":\"2002\",
                    \"price\":\"456.00\"},{\"title\":\"AdobeFlex\",\"author\":\"Johnson\",
                    \"year\":\"2010\",\"price\":\"566.00\"}]}}
                    """
    }

    func testConstructors() {
        XCTAssertThrowsError(try JSON(json: "}" + JSONS.simple))
        XCTAssertThrowsError(try JSON(json: "}" + JSONS.oneSubstruct))
        XCTAssertThrowsError(try JSON(json: "}" + JSONS.medium))

        XCTAssertNoThrow(try JSON(json: JSONS.simple))
        XCTAssertNoThrow(try JSON(json: JSONS.oneSubstruct))
        XCTAssertNoThrow(try JSON(json: JSONS.medium))

        XCTAssertThrowsError(try JSON(json: "}" + JSONS.simple))
        XCTAssertThrowsError(try JSON(json: "}" + JSONS.oneSubstruct))
        XCTAssertThrowsError(try JSON(json: "}" + JSONS.medium))
    }

    func testDictionary() {
        guard let json = try? JSON(json: JSONS.simple) else {
            fail()
            return
        }
        guard let root = json.dictionary else {
            fail()
            return
        }

        let root1 = json.dictionaryValue

        XCTAssert(!root1.isEmpty)
        XCTAssert(!root.isEmpty)

        XCTAssert(json["id"].dictionaryValue.isEmpty)
        XCTAssert(json["id"].dictionary == nil)
        XCTAssert(json["smth"].isNil)

        XCTAssert(json["id"].intValue == root["id"]?.intValue)
        XCTAssert(json["name"].stringValue == root["name"]?.stringValue)
        XCTAssert(json["age"].intValue == root["age"]?.intValue)

        XCTAssert(root1 == root)
    }

    func testArray() {
        guard let json = try? JSON(json: JSONS.medium) else {
            fail()
            return
        }

        guard let arr = json["books"]["book"].array else {
            fail()
            return
        }

        XCTAssert(arr.count == 3)

        XCTAssert(json["books"].array == nil)
        XCTAssert(json["books"].arrayValue.count == 0)

        XCTAssert(arr.first!["title"].stringValue == "CPP")

        XCTAssert(json["books"]["book"][0]["title"] == JSON(from: "CPP"))
        XCTAssert(json["books"]["book"][-1].isNil)
        XCTAssert(json["books"]["book"][1000].isNil)
    }

    func testString() {
        guard let json = try? JSON(json: JSONS.simple) else {
            fail()
            return
        }

        let id = json["id"]
        XCTAssert(id.string == nil)
        XCTAssert(id.stringValue == "")

        let notExists = json["notExists"]
        XCTAssert(notExists.string == nil)
        XCTAssert(notExists.stringValue == "")

        let name = json["name"]

        XCTAssert(name.string == name.stringValue)
        XCTAssert(name.stringValue == "Thom")
    }

    func testInt() {
        guard let json = try? JSON(json: JSONS.simple) else {
            fail()
            return
        }

        let id = json["id"]
        XCTAssertEqual(id.int, id.intValue)
        XCTAssertEqual(id.intValue, 1)

        let notExists = json["notExists"]
        XCTAssert(notExists.int == nil)
        XCTAssert(notExists.intValue == 0)

        let name = json["name"]
        XCTAssert(name.int == nil)
        XCTAssert(name.intValue == 0)
    }

    func testDouble() {
        guard let json = (try? JSON(json: JSONS.oneSubstruct))?.dictionaryValue["c"] else {
            fail()
            return
        }

        let double = json["double"]
        XCTAssert(double.double == double.doubleValue)
        XCTAssert(double.doubleValue == 3.1)

        let notExists = json["notExists"]
        XCTAssert(notExists.double == nil)
        XCTAssert(notExists.doubleValue == 0.0)

        let a = json["a"]
        XCTAssert(a.double == nil)
        XCTAssert(a.doubleValue == 0.0)
    }

    func testBool() {
        guard let json = (try? JSON(json: JSONS.oneSubstruct))?.dictionaryValue["c"] else {
            fail()
            return
        }

        let bool = json["bool"]
        XCTAssertEqual(bool.bool, bool.boolValue)
        XCTAssertEqual(bool.boolValue, true)

        let notExists = json["notExists"]
        XCTAssert(notExists.bool == nil)
        XCTAssert(notExists.boolValue == false)

        let double = json["double"]
        XCTAssert(double.bool == nil)
        XCTAssert(double.boolValue == false)
    }

    func testNilJSON() {
        let json = JSON(from: nil)!

        XCTAssert(json.isNil)
        XCTAssert(json["smth"].isNil)
    }

    func testIsEmpty() {
        guard let json = try? JSON(json: JSONS.medium) else {
            fail()
            return
        }

        let arr = json["books"]["book"]

        XCTAssert(!arr.isEmpty)
        XCTAssert(!json.isEmpty)
        XCTAssertTrue(json["smth"].isEmpty)
        XCTAssert(!arr.arrayValue.first!["title"].isEmpty)
    }

    func testEq() {
        guard let json1 = try? JSON(json: JSONS.medium) else {
            fail()
            return
        }
        guard let json2 = try? JSON(json: JSONS.medium) else {
            fail()
            return
        }
        guard let json3 = try? JSON(json: JSONS.oneSubstruct) else {
            fail()
            return
        }

        XCTAssert(json1 == json2)
        XCTAssert(json1 != json3)
        XCTAssert(json2 != json3)
    }

    func testCodableSimple() {
        XCTAssertTrue(checkCodable(json: JSONS.simple))
    }

    func testCodableOneSubstruct() {
        XCTAssertTrue(checkCodable(json: JSONS.oneSubstruct))
    }

    func testCodableMedium() {
        XCTAssertTrue(checkCodable(json: JSONS.medium))
    }

    private func checkCodable(json jsonString: String) -> Bool {
        guard let json1 = try? JSON(json: jsonString) else {
            XCTFail()
            return false
        }
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(json1) else {
            XCTFail()
            return false
        }
        guard let string = String(data: data, encoding: .utf8) else {
            XCTFail()
            return false
        }
        guard let json2 = try? JSON(json: string) else {
            XCTFail()
            return false
        }
        let decoder = JSONDecoder()
        guard let json3 = try? decoder.decode(JSON.self, from: data) else {
            XCTFail()
            return false
        }
        XCTAssertEqual(json1, json2)
        XCTAssertEqual(json2, json3)
        XCTAssertEqual(json1, json3)
        return json1 == json2 && json2 == json3 && json1 == json3
    }
    static let allTests = [
        ("testConstructors", testConstructors),
        ("testDictionary", testDictionary),
        ("testArray", testArray),
        ("testString", testString),
        ("testInt", testInt),
        ("testDouble", testDouble),
        ("testBool", testBool),
        ("testNilJSON", testNilJSON),
        ("testIsEmpty", testIsEmpty),
        ("testEq", testEq),
        ("testCodableSimple", testCodableSimple),
        ("testCodableOneSubstruct", testCodableOneSubstruct),
        ("testCodableMedium", testCodableMedium)
    ]
}

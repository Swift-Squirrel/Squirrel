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
        static let oneSubstruct = "{\"a\":3,\"c\":{\"a\":\"SubStruct\",\"double\":3.1,\"bool\":true}}"
        static let medium = """
                    {\"books\":{\"book\":[{\"title\":\"CPP\",\"author\":\"Milton\",\"year\":\"2008\",
                    \"price\":\"456.00\"},{\"title\":\"JAVA\",\"author\":\"Gilson\",\"year\":\"2002\",
                    \"price\":\"456.00\"},{\"title\":\"AdobeFlex\",\"author\":\"Johnson\",
                    \"year\":\"2010\",\"price\":\"566.00\"}]}}
                    """
    }

    func testConstructors() {
        XCTAssertThrowsError(try JSON(string: "}" + JSONS.simple))
        XCTAssertThrowsError(try JSON(string: "}" + JSONS.oneSubstruct))
        XCTAssertThrowsError(try JSON(string: "}" + JSONS.medium))

        XCTAssertNoThrow(try JSON(string: JSONS.simple))
        XCTAssertNoThrow(try JSON(string: JSONS.oneSubstruct))
        XCTAssertNoThrow(try JSON(string: JSONS.medium))

        do {
            _ = try JSON(string: "}" + JSONS.simple)
        } catch let error {
            if let err = error as? JSONError {
                if err.kind != JSONError.ErrorKind.parseError {
                    fail(err.message)
                }
            } else {
                fail(String(describing: error))
            }
        }
        do {
            _ = try JSON(string: "}" + JSONS.oneSubstruct)
        } catch let error {
            if let err = error as? JSONError {
                if err.kind != JSONError.ErrorKind.parseError {
                    fail(err.message)
                }
            } else {
                fail(String(describing: error))
            }
        }
        do {
            _ = try JSON(string: "}" + JSONS.medium)
        } catch let error {
            if let err = error as? JSONError {
                if err.kind != JSONError.ErrorKind.parseError {
                    fail(err.message)
                }
            } else {
                fail(String(describing: error))
            }
        }
    }

    func testDictionary() {
        guard let json = try? JSON(string: JSONS.simple) else {
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
        guard let json = try? JSON(string: JSONS.medium) else {
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
        guard let json = try? JSON(string: JSONS.simple) else {
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
        guard let json = try? JSON(string: JSONS.simple) else {
            fail()
            return
        }

        let id = json["id"]
        XCTAssert(id.int == id.intValue)
        XCTAssert(id.intValue == 1)

        let notExists = json["notExists"]
        XCTAssert(notExists.int == nil)
        XCTAssert(notExists.intValue == 0)

        let name = json["name"]
        XCTAssert(name.int == nil)
        XCTAssert(name.intValue == 0)
    }

    func testDouble() {
        guard let json = (try? JSON(string: JSONS.oneSubstruct))?.dictionaryValue["c"] else {
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
        guard let json = (try? JSON(string: JSONS.oneSubstruct))?.dictionaryValue["c"] else {
            fail()
            return
        }

        let bool = json["bool"]
        XCTAssert(bool.bool == bool.boolValue)
        XCTAssert(bool.boolValue == true)

        let notExists = json["notExists"]
        XCTAssert(notExists.bool == nil)
        XCTAssert(notExists.boolValue == false)

        let double = json["double"]
        XCTAssert(double.bool == nil)
        XCTAssert(double.boolValue == false)
    }

    func testAny() {
        guard let json = try? JSON(string: JSONS.simple) else {
            fail()
            return
        }

        XCTAssertNotNil(json.any)

        guard let data = json.any as? [String: Any] else {
            XCTFail()
            return
        }//{\"id\":1,\"name\":\"Thom\",\"age\":21}

        XCTAssertEqual(data["id"] as? Int, 1)
        XCTAssertEqual(data["name"] as? String, "Thom")
        XCTAssertEqual(data["age"] as? Int, 21)

        XCTAssertNil(JSON(from: nil).any)
    }

    func testNilJSON() {
        let json = JSON(from: nil)

        XCTAssert(json.isNil)
        XCTAssert(json["smth"].isNil)
    }

    func testIsEmpty() {
        guard let json = try? JSON(string: JSONS.medium) else {
            fail()
            return
        }

        let arr = json["books"]["book"]

        XCTAssert(!arr.isEmpty)
        XCTAssert(!json.isEmpty)
        XCTAssert(json["smth"].isEmpty)
        XCTAssert(!arr.arrayValue.first!["title"].isEmpty)
    }

    func testEq() {
        guard let json1 = try? JSON(string: JSONS.medium) else {
            fail()
            return
        }
        guard let json2 = try? JSON(string: JSONS.medium) else {
            fail()
            return
        }
        guard let json3 = try? JSON(string: JSONS.oneSubstruct) else {
            fail()
            return
        }

        XCTAssert(json1 == json2)
        XCTAssert(json1 != json3)
        XCTAssert(json2 != json3)
    }

    static let allTests = [
        ("testConstructors", testConstructors),
        ("testDictionary", testDictionary),
        ("testArray", testArray),
        ("testString", testString),
        ("testInt", testInt),
        ("testDouble", testDouble),
        ("testBool", testBool),
        ("testAny", testAny),
        ("testNilJSON", testNilJSON),
        ("testIsEmpty", testIsEmpty),
        ("testEq", testEq)
    ]
}

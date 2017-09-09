//
//  NutParserErrors.swift
//  NutViewTests
//
//  Created by Filip Klembara on 9/7/17.
//

import XCTest
@testable import NutView

class NutParserErrors: XCTestCase {

    func testDateTokenErrors() {
        let name = "Views/Main.nut"
        var content = "\n\\Date()"
        var expect = NutParserError(kind: .syntaxError(expected: ["Date(<expression: Double>, format: <expression: String>)",
                                                                  "Date(<expression: Double>)"], got: ")"), row: 2)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Date()")

        content = "\n\n\\Date(\"dwa ada - a) fea \n\ne"
        expect = NutParserError(
            kind: .syntaxError(
                expected: ["Date(<expression: Double>, format: <expression: String>)",
                           "Date(<expression: Double>)"],
                got: "\"dwa ada - a) fea \n\ne"),
            row: 3,
            description: "missing '\")'")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing string end '\"' in:\n\(content)\n")

        content = "\n\n\\Date(\"dwa ada\",)"
        expect = NutParserError(kind: .syntaxError(expected: [" format: <expression: String>"], got: ")"), row: 3)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing 'format' label in:\n\(content)\n")

        content = "\n\n\\Date(\"dwa ada\",format: 3)"
        expect = NutParserError(kind: .syntaxError(expected: [" format: <expression: String>"], got: "format: 3)"), row: 3)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing space between ',' and 'format' label in:\n\(content)\n")

        content = "\n\\Date(\"dwa ada\",forma)"
        expect = NutParserError(kind: .syntaxError(expected: [" format: <expression: String>"], got: "forma)"), row: 2)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Unknown overload 'Date(_:forma:)' in:\n\(content)\n")
    }

    func testIfErrors() {
        let name = "Views/Main.nut"
        var content = "\n\\if {"
        let expected = ["if <expression: Bool> {", "if let <variableName: Any> = <expression: Any?> {"]
        var expect = NutParserError(kind: .syntaxError(expected: expected, got: "if {"), row: 2, description: "empty <expression>")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Empty condition")

        content = "\n\n\n\n\\if let { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "if let {"), row: 5, description: "empty <expression>")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Empty condition")

        content = "\n\n\n\n\\if let asd = pom + 2 { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "if let asd = pom + 2 {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Non nil value")

        content = "\n\n\n\n\\if let asd as = { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "if let asd as = {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Wrong param order")

        content = "\n\n\n\n\\if let = asd as { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "if let = asd as {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Wrong param order")


        content = "\n\n\n\n\\if let asd == par { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "if let asd == par {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing '='")

        content = "\n\n\n\n\\if par \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "if par "), row: 5, description: "'{' not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Wrong param order")

        content = "\n\n\n\n\\if let asd as = \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "if let asd as = "), row: 5, description: "'{' not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Wrong param order")
    }

    func testElseIfErrors() {
        let name = "Views/Main.nut"
        var content = "\n\\} else if {"
        let expected = ["} else if <expression: Bool> {", "} else if let <variableName: Any> = <expression: Any?> {"]
        var expect = NutParserError(kind: .syntaxError(expected: expected, got: "} else if {"), row: 2, description: "empty <expression>")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Empty condition")

        content = "\n\n\n\n\\} else if let { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "} else if let {"), row: 5, description: "empty <expression>")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Empty condition")

        content = "\n\n\n\n\\} else if let asd = pom + 2 { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "} else if let asd = pom + 2 {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Non nil value")

        content = "\n\n\n\n\\} else if let asd as = { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "} else if let asd as = {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Wrong param order")

        content = "\n\n\n\n\\} else if let = asd as { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "} else if let = asd as {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Wrong param order")


        content = "\n\n\n\n\\} else if let asd == par { \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "} else if let asd == par {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing '='")

        content = "\n\n\n\n\\} else if par \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "} else if par "), row: 5, description: "'{' not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Wrong param order")

        content = "\n\n\n\n\\} else if let asd as = \\}"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "} else if let asd as = "), row: 5, description: "'{' not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Wrong param order")
    }

    func testLayoutErrors() {
        let name = "Views/Main.nut"
        var content = "\n\\Layout(\"deasd"
        let expected = ["Layout(\"<name>\")"]
        var expect = NutParserError(kind: .syntaxError(expected: expected, got: "deasd"), row: 2, description: "missing '\")'")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing \" in String")

        content = "\n\n\n\n\\Layout(\" asd ad \" + a)"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " asd ad \" + a)"), row: 5, description: "missing '\")'")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "expresion as argument")
    }

    func testSubviewErrors() {
        let name = "Views/Main.nut"
        var content = "\n\\Subview(\"deasd"
        let expected = ["Subview(\"<name>\")"]
        var expect = NutParserError(kind: .syntaxError(expected: expected, got: "deasd"), row: 2, description: "missing '\")'")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing \" in String")

        content = "\n\n\n\n\\Subview(\" asd ad \" + a)"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " asd ad \" + a)"), row: 5, description: "missing '\")'")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "expresion as argument")
    }

    func testTitleErrors() {
        let name = "Views/Main.nut"
        let content = "\n\\Title(\"deasd"
        let expected = ["(<expression: Any>)"]
        var expect = NutParserError(kind: .syntaxError(expected: expected, got: "(\"deasd"), row: 2, description: "missing ')'")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing \" in String")
    }

    func testForErrors() {
        let name = "Views/Main.nut"
        let expected = ["for <variable: Any> in <array: [Any]> {", "for (<key: String>, <value: Any>) in <dictionary: [String: Value> {"]
        var content = "\n\\for "
        var expect = NutParserError(kind: .syntaxError(expected: expected, got: "for "), row: 2, description: "'{' not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing '{'")

        content = "\n\n\n\n\\for ds ea sd ads s \\} {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "for ds ea sd ads s "), row: 5, description: "'{' not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing '{'")

        content = "\n\n\n\n\\for ds at blah {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " ds at blah "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "'at' insted of 'in'")

        content = "\n\n\n\n\\for ds in blah 3ra {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " ds in blah 3ra "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for ds in blah 3ra {")

        // next
        content = "\n\n\n\n\\for (ds, as) ea sd ads s \\} {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "for (ds, as) ea sd ads s "), row: 5, description: "'{' not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing '{'")

        content = "\n\n\n\n\\for (ds, as) at blah {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " (ds, as) at blah "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "'at' insted of 'in'")

        content = "\n\n\n\n\\for (ds, as) in blah 3ra {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " (ds, as) in blah 3ra "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for ds (ds, as) blah 3ra {")


        content = "\n\n\n\n\\for (ds,as) in blah {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " (ds,as) in blah "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for (ds,as) in blah {")

        content = "\n\n\n\n\\for ds,as in blah {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " ds,as in blah "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for ds,as in blah {")

        content = "\n\n\n\n\\for (ds,as in blah {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " (ds,as in blah "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for (ds,as in blah {")

        content = "\n\n\n\n\\for ds,as) in blah {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " ds,as) in blah "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for ds,as) in blah {")

        content = "\n\n\n\n\\for ds, as in blah {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " ds, as in blah "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for ds, as in blah {")

        content = "\n\n\n\n\\for (ds, as in blah {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " (ds, as in blah "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for (ds, as in blah {")

        content = "\n\n\n\n\\for ds, as) in blah {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: " ds, as) in blah "), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for ds, as) in blah {")
    }

    func testExpressionErrors() {
        let name = "Views/Main.nut"
        let expected = ["(<expression: Any>)"]
        var content = "\n\\(asd a"
        var expect = NutParserError(kind: .syntaxError(expected: expected, got: "(asd a"), row: 2, description: "missing ')'")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing ')'")

        content = "\n\n\n\n\\() \\} {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "()"), row: 5, description: "Empty expression")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Empty expression")
    }

    func testRawValueErrors() {
        let name = "Views/Main.nut"
        let expected = ["RawValue(<expression: Any>)"]
        var content = "\n\\RawValue(asd a"
        var expect = NutParserError(kind: .syntaxError(expected: expected, got: "RawValue(asd a"), row: 2, description: "missing ')'")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Missing ')'")

        content = "\n\n\n\n\\RawValue() \\} {"
        expect = NutParserError(kind: .syntaxError(expected: expected, got: "RawValue()"), row: 5, description: "Empty expression")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Empty expression")
    }

    func testVariableName() {
        let name = "Views/Main.nut"
        var content = "\n\\if let 3a = asd {"
        var expect = NutParserError(kind: .wrongSimpleVariable(name: "3a", in: "if let 3a = asd {"), row: 2)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "if let '3a'")

        content = "\n\n\n\n\\if let name = 3a { \\} {"
        expect = NutParserError(kind: .wrongChainedVariable(name: "3a", in: "if let name = 3a {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "if let name = '3a'")

        content = "\n\n\n\n\\if let name = asd.3a { \\} {"
        expect = NutParserError(kind: .wrongChainedVariable(name: "asd.3a", in: "if let name = asd.3a {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "if let name = asd.'3a'")

        content = "\n\n\n\n\\if let name.da = asd { \\} {"
        expect = NutParserError(kind: .wrongSimpleVariable(name: "name.da", in: "if let name.da = asd {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "if let name'.da' = asd")

        // else if
        content = "\n\\} else if let 3a = asd {"
        expect = NutParserError(kind: .wrongSimpleVariable(name: "3a", in: "} else if let 3a = asd {"), row: 2)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "} else if let '3a'")

        content = "\n\n\n\n\\} else if let name = 3a { \\} {"
        expect = NutParserError(kind: .wrongChainedVariable(name: "3a", in: "} else if let name = 3a {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "} else if let name = '3a'")

        content = "\n\n\n\n\\} else if let name = asd.3a { \\} {"
        expect = NutParserError(kind: .wrongChainedVariable(name: "asd.3a", in: "} else if let name = asd.3a {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "} else if let name = asd.'3a'")

        content = "\n\n\n\n\\} else if let name.da = asd { \\} {"
        expect = NutParserError(kind: .wrongSimpleVariable(name: "name.da", in: "} else if let name.da = asd {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "} else if let name'.da' = asd")

        // for
        content = "\n\n\n\n\\for 4a in sda { \\} {"
        expect = NutParserError(kind: .wrongSimpleVariable(name: "4a", in: "for 4a in sda {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for '4a' in sda {")

        content = "\n\n\n\n\\for name.3a in asd3 { \\} {"
        expect = NutParserError(kind: .wrongSimpleVariable(name: "name.3a", in: "for name.3a in asd3 {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for name'.3a' in asd3 {")

        content = "\n\n\n\n\\for name in asd.3a { \\} {"
        expect = NutParserError(kind: .wrongChainedVariable(name: "asd.3a", in: "for name in asd.3a {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for name in asd'.3a' {")

        content = "\n\n\n\n\\for name in 3a { \\} {"
        expect = NutParserError(kind: .wrongChainedVariable(name: "3a", in: "for name in 3a {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for name in '.3a' {")

        // next
        content = "\n\n\n\n\\for (4a, asd) in sda { \\} {"
        expect = NutParserError(kind: .wrongSimpleVariable(name: "4a", in: "for (4a, asd) in sda {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for ('4a', asd) in sda {")

        content = "\n\n\n\n\\for (asd, 4a) in sda { \\} {"
        expect = NutParserError(kind: .wrongSimpleVariable(name: "4a", in: "for (asd, 4a) in sda {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for (asd, '4a') in sda {")

        content = "\n\n\n\n\\for (name.3a, asd) in asd3 { \\} {"
        expect = NutParserError(kind: .wrongSimpleVariable(name: "name.3a", in: "for (name.3a, asd) in asd3 {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for (name'.3a', asd) in asd3 {")

        content = "\n\n\n\n\\for (asd, name.3a) in asd3 { \\} {"
        expect = NutParserError(kind: .wrongSimpleVariable(name: "name.3a", in: "for (asd, name.3a) in asd3 {"), row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for (asd, name'.3a') in asd3 {")
    }

    func testUnexpectedEndIf() {
        let name = "Views/Main.nut"
        var content = "\n\\if let a = asd { asd s"
        var expect = NutParserError(kind: .unexpectedEnd(reading: "if let"), row: 2, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "if let")

        content = "\n\n\n\n\\if a == b { asd s"
        expect = NutParserError(kind: .unexpectedEnd(reading: "if"), row: 5, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "if")

        content = "\n\n\n\n\\if let a = b { asd \\} else { s"
        expect = NutParserError(kind: .unexpectedEnd(reading: "else"), row: 5, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "else")

        content = "\n\n\n\n\\if a == b { asd \\} else { s"
        expect = NutParserError(kind: .unexpectedEnd(reading: "else"), row: 5, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "else")


        content = "\n\n\n\n\\if a == b { asd \\} else if b == c { s"
        expect = NutParserError(kind: .unexpectedEnd(reading: "else if"), row: 5, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "else if")

        content = "\n\n\n\n\\if a == b { asd \\} else if let b = c { s"
        expect = NutParserError(kind: .unexpectedEnd(reading: "else if let"), row: 5, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "else if let")


        content = "\n\n\n\n\\if a == b { asd \\} else if b == c {  a \\} else {\ns"
        expect = NutParserError(kind: .unexpectedEnd(reading: "else"), row: 5, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "else")

        content = "\n\n\n\n\\if a == b { asd \\} else if let b = c {  a \\} else { s"
        expect = NutParserError(kind: .unexpectedEnd(reading: "else"), row: 5, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "else")

        content = "\n\n\n\n\\if a == b { asd \\} \\}"
        expect = NutParserError(kind: .unexpectedBlockEnd, row: 5)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "unexpected '\\}'")
    }

    func testUnexpectedEndFor() {
        let name = "Views/Main.nut"
        var content = "\\for a in b { asd s"
        var expect = NutParserError(kind: .unexpectedEnd(reading: "for in Array"), row: 1, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for in Array")

        content = "\n\n\n\n\n\n\\for (a, b) in c { asd s"
        expect = NutParserError(kind: .unexpectedEnd(reading: "for in Dictionary"), row: 7, description: "\\} not found")
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "for in Dictionary")

        content = "\n\n\n\n\n\n\\for (a, b) in c { asd s \\} \\}"
        expect = NutParserError(kind: .unexpectedBlockEnd, row: 7)
        expect.name = name
        XCTAssertTrue(checkError(for: content, expect: expect), "Unexpected '\\}'")
    }

    private func checkError(for content: String, expect: NutParserError) -> Bool {
        let parser = NutParser(content: content, name: "Views/Main.nut")

        do {
            _ = try parser.tokenize()
            XCTFail("No error from: \n=====>\n\(content)\n<=====\n")
        } catch let error as NutParserError {
            XCTAssertEqual(expect.description, error.description)
            if expect.description == error.description {
                return true
            }
        } catch let error {
            XCTFail(String(describing: error))
        }
        return false
    }

    static let allTests = [
        ("testDateTokenErrors", testDateTokenErrors),
        ("testIfErrors", testIfErrors),
        ("testElseIfErrors", testElseIfErrors),
        ("testLayoutErrors", testLayoutErrors),
        ("testSubviewErrors", testSubviewErrors),
        ("testTitleErrors", testTitleErrors),
        ("testForErrors", testForErrors),
        ("testExpressionErrors", testExpressionErrors),
        ("testRawValueErrors", testRawValueErrors),
        ("testVariableName", testVariableName),
        ("testUnexpectedEndIf", testUnexpectedEndIf),
        ("testUnexpectedEndFor", testUnexpectedEndFor)
    ]

}

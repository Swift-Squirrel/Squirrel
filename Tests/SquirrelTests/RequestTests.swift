//
//  RequestTests.swift
//  SquirrelTests
//
//  Created by Filip Klembara on 9/11/17.
//

import XCTest
@testable import Squirrel

class RequestTests: XCTestCase {

    private struct RequestTemplates {
        static let get = """
            GET /tutorials/other/top-20-mysql-best-practices/ HTTP/1.1\r
            Host: net.tutsplus.com
            User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5 (.NET CLR 3.5.30729)\r
            Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r
            Accept-Language: en-us,en;q=0.5\r
            Accept-Encoding: gzip,deflate\r
            Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.7\r
            Keep-Alive: 300\r
            Connection: keep-alive\r
            Cookie: PHPSESSID=r2t5uvjq435r4q7ib3vtdjq120\r
            Pragma: no-cache\r
            Cache-Control: no-cache\r\n\r\n
            """.data(using: .utf8)!
        static let getParams = """
            GET /foo.php?first_name=John&last_name=Doe&action=Submit HTTP/1.1\r
            Accept-Encoding: gzip\r\n\r\n
            """.data(using: .utf8)!
        static let postParams = """
            POST /foo.php HTTP/1.1\r
            Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8\r
            Accept-Encoding: gzip,deflate\r
            Referer: http://localhost/test.php\r
            Content-Type: application/x-www-form-urlencoded\r
            Content-Length: 43\r
            \r
            first_name=John&last_name=Doe&action=Submit
            """.data(using: .utf8)!
    }
    private struct RequestErrors {
        static let unseparatedHead = [
            "POST /foo.php HTTP/1.1\r".data(using: .utf8)!,
            "POST /foo.php HTTP/1.1\r\nContent-Length: 43\r\nfirst_name=John&last_name=Doe&action=Submit".data(using: .utf8)!
        ]
        static let wrongFirstLine: [(data: Data, expect: RequestError)] = [
            (data: "POST foo.php HTTP/1.1\r\n\r\n".data(using: .utf8)!,
             expect: RequestError(kind: .headParseError)),
            (data: "POST foo.php  HTTP/1.1\r\n\r\n".data(using: .utf8)!,
             expect: RequestError(kind: .headParseError)),
            (data: "POST HTTP/1.1\r\n\r\n".data(using: .utf8)!,
             expect: RequestError(kind: .headParseError)),
            (data: "POST\r\n\r\n".data(using: .utf8)!,
             expect: RequestError(kind: .headParseError)),
            (data: "POST  HTTP/1.1\r\n\r\n".data(using: .utf8)!,
             expect: RequestError(kind: .headParseError))
        ]
        static let wrongMethod: [(data: Data, method: String)] = [
            (data: "POSTA /foo//%20.php HTTP/1.1\r\n\r\n".data(using: .utf8)!, method: "POSTA"),
            (data: "GetG /foo//%20.php HTTP/1.1\r\n\r\n".data(using: .utf8)!, method: "GETG"),
            (data: "NOTHING /foo//%20.php HTTP/1.1\r\n\r\n".data(using: .utf8)!, method: "NOTHING"),
            (data: "BLAH /foo//%20.php HTTP/1.1\r\n\r\n".data(using: .utf8)!, method: "BLAH"),
        ]

        static let unknownProtocol: [(data: Data, prot: String)] = [
            (data: "POST /foo//%20.php HTTP/1\r\n\r\n".data(using: .utf8)!, prot: "HTTP/1"),
            (data: "GET /foo//%20.php HTTP/1.0\r\n\r\n".data(using: .utf8)!, prot: "HTTP/1.0"),
            (data: "PUT /foo//%20.php HTTP\r\n\r\n".data(using: .utf8)!, prot: "HTTP"),
            (data: "DELETE /foo//%20.php SMTHASD\r\n\r\n".data(using: .utf8)!, prot: "SMTHASD"),
        ]

        static let wrongHead: [(data: Data, expect: RequestError)] = [
            (data: "POST /foo.php HTTP/1.1\r\nKeep-Alive 300\r\n\r\n".data(using: .utf8)!,
             expect: RequestError(kind: .headParseError)),
        ]
    }

    func testValidInit() {
        XCTAssertNoThrow(try Request(data: RequestTemplates.get))
        guard let request = try? Request(data: RequestTemplates.get) else {
            XCTFail()
            return
        }

        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.acceptEncoding, [.gzip, .deflate])
        XCTAssertEqual(request.path, "/tutorials/other/top-20-mysql-best-practices")
        XCTAssertEqual(request.urlParameters.count, 0)
        XCTAssertTrue(request.postParameters.isEmpty)
        XCTAssertTrue(request.getParameters.isEmpty)
        XCTAssertEqual(request.getCookie(for: "PHPSESSID"), "r2t5uvjq435r4q7ib3vtdjq120")
        XCTAssertEqual(request.cookies.count, 1)
        XCTAssertEqual(request.getHeader(for: "Accept-Charset"), "ISO-8859-1,utf-8;q=0.7,*;q=0.7")
    }

    func testGetParams() {
        XCTAssertNoThrow(try Request(data: RequestTemplates.getParams))
        guard let request = try? Request(data: RequestTemplates.getParams) else {
            XCTFail()
            return
        }

        XCTAssertEqual(request.method, .get)
        XCTAssertEqual(request.acceptEncoding, [.gzip])
        XCTAssertEqual(request.path, "/foo.php")
        XCTAssertEqual(request.urlParameters.count, 0)
        XCTAssertTrue(request.postParameters.isEmpty)
        XCTAssertEqual(request.getParameters.count, 3)
        let getParams: [String: String] = [
            "first_name": "John",
            "last_name": "Doe",
            "action": "Submit"
        ]
        XCTAssertEqual((request.getParameters as? [String: String]) ?? [:], getParams)
        XCTAssertNotNil(request.getGetParameter(for: "first_name"))
        XCTAssertEqual(request.getGetParameter(for: "first_name"), getParams["first_name"]!)
        XCTAssertNotNil(request.getGetParameter(for: "last_name"))
        XCTAssertEqual(request.getGetParameter(for: "last_name"), getParams["last_name"]!)
        XCTAssertNotNil(request.getGetParameter(for: "action"))
        XCTAssertEqual(request.getGetParameter(for: "action"), getParams["action"]!)
    }

    func testPostParams() {
        XCTAssertNoThrow(try Request(data: RequestTemplates.postParams))
        guard let request = try? Request(data: RequestTemplates.postParams) else {
            XCTFail()
            return
        }

        XCTAssertEqual(request.method, .post)
        XCTAssertEqual(request.path, "/foo.php")
        XCTAssertEqual(request.urlParameters.count, 0)
        XCTAssertEqual(request.getHeader(for: "Referer"), "http://localhost/test.php")
        XCTAssertTrue(request.getParameters.isEmpty)
        XCTAssertEqual(request.postParameters.count, 3)
        let postParams: [String: String] = [
            "first_name": "John",
            "last_name": "Doe",
            "action": "Submit"
        ]
        XCTAssertEqual(request.postParameters, postParams)
        XCTAssertNotNil(request.getPostParameter(for: "first_name"))
        XCTAssertEqual(request.getPostParameter(for: "first_name"), postParams["first_name"]!)
        XCTAssertNotNil(request.getPostParameter(for: "last_name"))
        XCTAssertEqual(request.getPostParameter(for: "last_name"), postParams["last_name"]!)
        XCTAssertNotNil(request.getPostParameter(for: "action"))
        XCTAssertEqual(request.getPostParameter(for: "action"), postParams["action"]!)
    }

    func testURLParams() {
        XCTAssertNoThrow(try Request(data: RequestTemplates.get))
        guard let request = try? Request(data: RequestTemplates.get) else {
            XCTFail()
            return
        }
        request.setURLParameter(key: "urlTitle", value: "top-20-mysql-best-practices")

        let urlParams: [String: String] = [
            "urlTitle": "top-20-mysql-best-practices"
        ]
        XCTAssertEqual(request.urlParameters, urlParams)
        XCTAssertEqual(request.getURLParameter(for: "urlTitle"), urlParams["urlTitle"]!)
    }

    func testUnseparatableHead() {
        let expect = RequestError(kind: .headParseError)
        RequestErrors.unseparatedHead.forEach({
            XCTAssertTrue(checkInitError(data: $0, expect: expect), String(data: $0, encoding: .utf8)!)
        })
    }

    func testWrongFirstLine() {
        RequestErrors.wrongFirstLine.forEach({
            XCTAssertTrue(checkInitError(data: $0.data, expect: $0.expect), String(data: $0.data, encoding: .utf8)!)
        })
    }

    func testWrongMethod() {
        RequestErrors.wrongMethod.forEach({
            XCTAssertTrue(checkInitError(data: $0.data, expect: RequestError(kind: .unknownMethod(method: $0.method))), String(data: $0.data, encoding: .utf8)!)
        })
    }

    func testUnknownProtocol() {
        RequestErrors.unknownProtocol.forEach({
            XCTAssertTrue(checkInitError(data: $0.data, expect: RequestError(kind: .unknownProtocol(prot: $0.prot))), String(data: $0.data, encoding: .utf8)!)
        })
    }

    func testWrongHead() {
        RequestErrors.wrongHead.forEach({
            XCTAssertTrue(checkInitError(data: $0.data, expect: $0.expect), String(data: $0.data, encoding: .utf8)!)
        })
    }

    func testUnsupportedMediaType() {
        do {
            _ = try Request(data: "POST /foo.php HTTP/1.1\r\n\r\n".data(using: .utf8)!)
        } catch let error as HTTPError {
            XCTAssertEqual(error.description, HTTPError(status: .unsupportedMediaType, description: "Missing Content-Type").description)
        } catch let error {
            XCTFail("Unexpected error '\(String(describing: type(of: error)))': \(error)")
        }

        do {
            _ = try Request(data: "POST /foo.php HTTP/1.1\r\nContent-Type: application/json\r\n\r\n".data(using: .utf8)!)
        } catch let error as HTTPError {
            XCTAssertEqual(error.description, HTTPError(status: .unsupportedMediaType, description: "Unsupported Content-Type").description)
        } catch let error {
            XCTFail("Unexpected error '\(String(describing: type(of: error)))': \(error)")
        }
    }

    private func checkInitError(data: Data, expect: RequestError) -> Bool {
        do {
            let _ = try Request(data: data)
            XCTFail()
        } catch let error as RequestError {
            XCTAssertEqual(error.description, expect.description)
            if error.description == expect.description {
                return true
            }
        } catch let error {
            XCTFail("Unexpected error '\(String(describing: type(of: error)))': \(error)")
        }
        return false
    }

    static var allTests = [
        ("validInit", testValidInit),
        ("testGetParams", testGetParams),
        ("testPostParams", testPostParams),
        ("testURLParams", testURLParams),
        ("testUnseparatableHead", testUnseparatableHead),
        ("testWrongFirstLine", testWrongFirstLine),
        ("testWrongMethod", testWrongMethod),
        ("testUnknownProtocol", testUnknownProtocol),
        ("testWrongHead", testWrongHead),
        ("testUnsupportedMediaType", testUnsupportedMediaType)
    ]
}

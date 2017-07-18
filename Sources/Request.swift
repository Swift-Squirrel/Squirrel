//
//  Request.swift
//  Micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation
import Regex

enum MyError: Error {
    case unknownError

    case responseError(errResponse: Response)
}

struct ResponseError: Error {
    let response: Response

    init(response: Response) {
        self.response = response
    }
}

class Request {

    private var requestType = ""

    private let _method: HTTPHeaders.Method

    var method: HTTPHeaders.Method {
        return _method
    }
    private let _path: URL

    var path: String {
        return _path.absoluteString
    }
    private let httpProtocol: String
    //    private let host: URL
    private let rawHeader: String
    private let rawBody: String

    private var headers: [String: String] = [:]

    private var urlParameters: [String: String] = [:]
    private var getParameters: [String: String] = [:]
    private var postParameters: [String: String] = [:]

    init(data: Data) throws {
        guard let stringData = String(data: data, encoding: .utf8) else {
            // todo throws
            throw MyError.unknownError
//            return
        }
        var rows = stringData.components(separatedBy: "\r\n\r\n")
        if rows.count != 2 {
            // throw
            throw MyError.unknownError
//            return
        }
        rawHeader = rows[0]
        rawBody = rows[1]

        rows = rawHeader.components(separatedBy: "\r\n")
        let row = rows[0]
        let components = row.components(separatedBy: " ")
        if components.count != 3 {
            throw MyError.unknownError
        }
        guard let p = URL(string: components[1]) else {
            throw MyError.unknownError
        }
        _path = p
        let methodRegex = Regex("^(post|get|delete|put)$")
        guard methodRegex.matches(components[0].lowercased()) == true else {
            throw MyError.unknownError
        }
        _method = HTTPHeaders.Method(rawValue: components[0]) ?? HTTPHeaders.Method.get

        guard components[2] == HTTPHeaders.HTTPProtocol.http11.rawValue else {
            throw MyError.unknownError
        }
        httpProtocol = components[2]

        rows.remove(at: 0)
        for row in rows {
            let pomArray = row.components(separatedBy: ": ")
            if pomArray.count != 2 {
                throw MyError.unknownError
            }

            headers[pomArray[0]] = pomArray[1]
        }
    }

    func setURLParameter(key: String, value: String) {
        urlParameters[key] = value
    }

    func getURLParameter(for key: String) -> String? {
        return urlParameters[key]
    }

    func getURLParameters() -> [String: String] {
        return urlParameters
    }

    func getHeader(for key: String) -> String? {
        return headers[key]
    }
}

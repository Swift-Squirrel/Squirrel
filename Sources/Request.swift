//
//  Request.swift
//  Micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation
import Regex

class Request {

    private var requestType = ""

    private let _method: HTTPHeaders.Method

    var method: HTTPHeaders.Method {
        return _method
    }
    private let _path: URL
    private let _fullpath: URL

    private var _cookies: [String: String] = [:]

    var path: String {
        return _path.absoluteString
    }
    private let httpProtocol: String
    //    private let host: URL
    private let rawHeader: String
    private let rawBody: String

    private var headers: [String: String] = [:]

    private var urlParameters: [String: String] = [:]
    private var _postParameters: [String: String] = [:]

    /// Init Request from data
    ///
    /// - Parameter data: Data of request
    /// - Throws: `DataError` and other parse errors
    /// - TODO: Do not parse body to string
    /// - Bug: When body contains binary data, init will fail
    init(data: Data) throws {
        guard let stringData = String(data: data, encoding: .utf8) else {
            throw DataError(kind: .dataEncodingError)
        }
        var rows = stringData.components(separatedBy: "\r\n\r\n")
        if rows.count != 2 {
            throw RequestError(kind: .unseparatableHead)
        }
        rawHeader = rows[0]
        rawBody = rows[1]

        rows = rawHeader.components(separatedBy: "\r\n")
        let row = rows[0]
        let components = row.components(separatedBy: " ")
        if components.count != 3 {
            throw RequestError(
                kind: .parseError(
                    string: row,
                    expectations: "String has to be separatable into exactly three parts divided by ' '."
                )
            )
        }


        guard let fullpath = URL(string: components[1]) else {
            throw RequestError(kind: .parseError(string: components[1], expectations: "Has to be parsable as URL."))
        }
        _fullpath = fullpath
        _path = URL(string: fullpath.path)!

        let methodRegex = Regex("^(post|get|delete|put|head|option)$")
        guard methodRegex.matches(components[0].lowercased()) == true else {
            throw RequestError(kind: .unknownMethod(method: components[0]))
        }
        _method = HTTPHeaders.Method(rawValue: components[0]) ?? HTTPHeaders.Method.get

        guard components[2] == HTTPHeaders.HTTPProtocol.http11.rawValue else {
            throw RequestError(kind: .unknownProtocol(prot: components[2]))
        }
        httpProtocol = components[2]

        rows.remove(at: 0)
        for row in rows {
            let pomArray = row.components(separatedBy: ": ")
            if pomArray.count != 2 {
                throw RequestError(kind: .parseError(
                    string: row,
                    expectations: "Header row has to be separatable by ': ' to two parts"
                    ))
            }

            headers[pomArray[0].lowercased()] = pomArray[1]
        }

        parseCookies()

        if _method == .post {
            try parsePostRequest()
        }
    }

    private func parseCookies() {
        guard let cookieLine = getHeader(for: "Cookie") else {
            return
        }

        let groups = cookieLine.components(separatedBy: "; ")
        for group in groups {
            let values = group.components(separatedBy: "=")
            guard values.count == 2 else {
                return
            }
            _cookies[values[0]] = values[1]
        }
    }

    private func parsePostRequest() throws {
        guard let contentType = getHeader(for: HTTPHeaders.ContentType.contentType) else {
            throw HTTPError(status: .unsupportedMediaType, description: "Missing \(HTTPHeaders.ContentType.contentType)")
        }

        switch contentType {
        case HTTPHeaders.ContentType.Application.formUrlencoded.rawValue:
            try parseURLEncoded(body: rawBody.data(using: .utf8)!) // TODO not as string
        default:
            throw HTTPError(status: .unsupportedMediaType, description: "Unsupported \(HTTPHeaders.ContentType.contentType)")
        }
    }

    private func parseURLEncoded(body data: Data) throws {
        guard let body = String(data: data, encoding: .utf8) else {
            throw DataError(kind: .dataEncodingError)
        }
        let groups = body.components(separatedBy: "&")
        for group in groups {
            var values = group.components(separatedBy: "=")
            guard values.count > 1 else {
                throw RequestError(kind: .postBodyParseError(errorString: group))
            }
            let key = values.removeFirst()
            let value = values.joined()
            _postParameters[key] = value
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

    func getGetParameter(for key: String) -> String? {
        return _fullpath[key]
    }

    func getPostParameter(for key: String) -> String? {
        return _postParameters[key]
    }

    var postParameters: [String: String] {
        return _postParameters
    }

    func getCookie(for key: String) -> String? {
        return _cookies[key]
    }
    var cookies: [String: String] {
        return _cookies
    }

    var getParameters: [String: String?] {
        return _fullpath.allQueryParams
    }

    func getHeader(for key: String) -> String? {
        return headers[key.lowercased()]
    }
}

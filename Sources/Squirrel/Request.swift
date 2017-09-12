//
//  Request.swift
//  Micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation
import Regex

/// Request class
open class Request {

    private var requestType = ""

    private let _method: HTTPHeaders.Method

    /// Request method
    public var method: HTTPHeaders.Method {
        return _method
    }
    private let _path: URL

    private var _cookies: [String: String] = [:]

    /// Accept-Encoding
    public var acceptEncoding = Set<HTTPHeaders.Encoding.EncodingType>()

    /// Request path
    public var path: String {
        return _path.path
    }
    private let httpProtocol: String
    //    private let host: URL
    private let rawHeader: String
    private let rawBody: String

    private var headers: [String: String] = [:]

    private var _urlParameters: [String: String] = [:]
    private var _postParameters: [String: String] = [:]

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
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
        var lines = stringData.components(separatedBy: "\r\n\r\n")
        if lines.count != 2 {
            throw RequestError(kind: .unseparatableHead)
        }
        rawHeader = lines[0]
        rawBody = lines[1]

        lines = rawHeader.components(separatedBy: "\r\n")
        let line = lines[0]
        let components = line.components(separatedBy: " ")
        if components.count != 3 {
            throw RequestError(
                kind: .parseError(
                    string: line,
                    expectations: "First line has to be separatable into "
                        + " three parts divided by ' '."
                )
            )
        }

        try components.forEach {
            (component: String) throws in
            guard !component.isEmpty else {
                throw RequestError(
                    kind: .parseError(
                        string: line,
                        expectations: "Empty component."
                    )
                )
            }
        }

        guard components[1].first == "/" else {
            throw RequestError(
                kind: .parseError(
                    string: components[1],
                    expectations: "URL prefix must be '/' not '\(components[1].first!)'."
                )
            )
        }

        guard let fullpath = URL(string: components[1]) else {
            throw RequestError(kind: .parseError(
                string: components[1],
                expectations: "Has to be parsable as URL."))
        }
        _path = fullpath

        let methodRegex = Regex("^(post|get|delete|put|head|option)$")
        guard methodRegex.matches(components[0].lowercased()) == true else {
            throw RequestError(kind: .unknownMethod(method: components[0]))
        }
        _method = HTTPHeaders.Method(rawValue: components[0]) ?? HTTPHeaders.Method.get

        guard components[2] == HTTPHeaders.HTTPProtocol.http11.rawValue else {
            throw RequestError(kind: .unknownProtocol(prot: components[2]))
        }
        httpProtocol = components[2]

        lines.remove(at: 0)
        for line in lines {
            let pomArray: [String] = line.split(
                separator: ":",
                maxSplits: 1,
                omittingEmptySubsequences: false).map({ String($0) })

            if pomArray.count != 2 || pomArray[1].first != " " {
                throw RequestError(kind: .parseError(
                    string: line,
                    expectations: "Header line has to be separatable by ': ' to two parts"
                    ))
            }
            headers[pomArray[0].lowercased()] = String(pomArray[1].dropFirst())
        }

        parseCookies()
        parseEncoding()

        if _method == .post {
            try parsePostRequest()
        }
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    private func parseEncoding() {
        guard var acceptLine = getHeader(for: "accept-encoding") else {
            return
        }
        acceptLine.replaceAll(matching: " ", with: "")
        let acceptable = acceptLine.components(separatedBy: ",")
        acceptable.forEach({ (encoding) in
            switch encoding {
            case "gzip":
                acceptEncoding.insert(.gzip)
            case "deflate":
                acceptEncoding.insert(.deflate)
            default:
                break
            }
        })

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
            throw HTTPError(
                status: .unsupportedMediaType,
                description: "Missing \(HTTPHeaders.ContentType.contentType)")
        }

        switch contentType {
        case HTTPHeaders.ContentType.Application.formUrlencoded.rawValue:
            try parseURLEncoded(body: rawBody.data(using: .utf8)!) // TODO not as string
        default:
            throw HTTPError(
                status: .unsupportedMediaType,
                description: "Unsupported \(HTTPHeaders.ContentType.contentType)")
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
}

// MARK: - Parameters
extension Request {
    /// Set URL parameter
    ///
    /// - Parameters:
    ///   - key: Parameter name
    ///   - value: Value
    func setURLParameter(key: String, value: String) {
        _urlParameters[key] = value
    }

    /// Return URL parameter
    ///
    /// URL parameters beginning with ':' in route for example
    ///
    ///     server().route(get: "/posts/:id") {
    ///         (id: ObjectId) in
    ///
    ///         return id
    ///     }
    ///
    /// is URL parameter id thanks to `"/posts/:id"`
    ///
    /// - Parameter key: Parameter name
    /// - Returns: Parameter value
    public func getURLParameter(for key: String) -> String? {
        return _urlParameters[key]
    }

    /// Returns all url parameters
    public var urlParameters: [String: String] {
        return _urlParameters
    }

    /// Returns parameter from URL
    ///
    /// GET parameters are after '?' in url for example in
    ///
    ///     "http://localhost/posts?name=Leo&age=21"
    ///
    /// are GET parameters *name* with value 'Leo' and *age* with value '21'
    ///
    /// - Parameter key: Parameter name
    /// - Returns: Parameter value
    public func getGetParameter(for key: String) -> String? {
        return _path[key]
    }

    /// Returns parameter coded in body of request
    ///
    /// - Parameter key: Parameter name
    /// - Returns: Parameter value
    public func getPostParameter(for key: String) -> String? {
        return _postParameters[key]
    }

    /// Returns all parameters coded in body of request
    public var postParameters: [String: String] {
        return _postParameters
    }

    /// Returns cookie
    ///
    /// - Parameter key: Cookie name
    /// - Returns: Cookie value
    public func getCookie(for key: String) -> String? {
        return _cookies[key]
    }

    /// Returns all cookies
    public var cookies: [String: String] {
        return _cookies
    }

    /// Returns all get parameters
    public var getParameters: [String: String?] {
        return _path.allQueryParams
    }

    /// Return header
    ///
    /// - Parameter key: Header name
    /// - Returns: Header value
    public func getHeader(for key: String) -> String? {
        return headers[key.lowercased()]
    }
}

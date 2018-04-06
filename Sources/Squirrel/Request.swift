//
//  Request.swift
//  Micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

// swiftlint:disable file_length

import Foundation
import Regex
import Socket
#if os(Linux)
    import Dispatch
#endif

/// Request class
open class Request {

    /// Request method
    public let method: RequestLine.Method

    private let _path: URL

    private var _cookies: [String: String] = [:]

    /// Hostname or IP
    public let remoteHostname: String

    /// Session builder used to create new sessions
    public var sessionBuilder: SessionBuilder = SessionManager()

    /// Accept-Encoding
    public private(set) var acceptEncoding = Set<HTTPHeader.Encoding>()

    /// Request path
    public var path: String {
        return _path.path
    }

    /// Request path with query parameters
    public let originalPath: String

    /// Protocol
    public let httpProtocol: RequestLine.HTTPProtocol

    /// HTTP Head
    public private(set) var headers: HTTPHead = [:]

    /// Request body
    public let body: Data

    /// Session
    private var _session: Session?

    private var _urlParameters: [String: String] = [:]
    private var _queryParameters: [String: String] = [:]
    private var _postParameters: [String: String] = [:]

    /// Requested range
    public let range: (bottom: UInt, top: UInt)?

    /// Post parameters when body is multipart
    public private(set) var postMultipart: [String: Multipart] = [:]

    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    private init(remoteHostname: String, buffer: Buffer) throws {
        self.remoteHostname = remoteHostname
        let method = (try buffer.readString(until: .space, allowEmpty: false)).uppercased()
        guard ["GET", "POST", "DELETE", "PUT", "PATCH"].contains(method) else {
            throw RequestError(kind: .unknownMethod(method: method))
        }
        self.method = RequestLine.Method(rawValue: method)!

        let pathString = try buffer.readString(until: .space, allowEmpty: false)
        guard pathString.first == "/" else {
            throw RequestError(kind: .headParseError)
        }
        originalPath = pathString
        guard let path = URL(string: pathString) else {
            throw RequestError(kind: .headParseError, description: "Could not parse url")
        }
        _path = path

        let protString = (try buffer.readString(until: .crlf, allowEmpty: false)).uppercased()
        guard let prot = RequestLine.HTTPProtocol(rawValue: protString) else {
            throw RequestError(kind: .unknownProtocol(prot: protString))
        }
        httpProtocol = prot
        var line = try buffer.readString(until: .crlf, allowEmpty: true)
        while !line.isEmpty {
            let arr = line.split(separator: ":", maxSplits: 1)
            guard arr.count == 2 else {
                throw RequestError(kind: .headParseError)
            }
            let key = String(arr.first!)
            var value = arr.last!
            guard !(key.isEmpty || value.isEmpty) else {
                throw RequestError(
                    kind: .headParseError,
                    description: "Wrong head format: \(key):\(value)")
            }
            if value.first == " " {
                _ = value.popFirst()
            }
            headers[key.lowercased()] = String(value)
            line = try buffer.readString(until: .crlf, allowEmpty: true)
        }

        if let lengthString = headers[.contentLength],
            let length = Int(lengthString) {
            body = try buffer.read(bytes: length)
        } else {
            body = Data()
        }
        var rang: (bottom: UInt, top: UInt)? = nil
        if let range = headers[.range] {
            if range.hasPrefix("bytes=") {
                let index = range.index(range.startIndex, offsetBy: 6)
                let inter = range[index...]
                let numbers = inter.split(separator: "-", maxSplits: 1)
                if numbers.count == 2 {
                    if let bottom = UInt(numbers.first!), let top = UInt(numbers.last!) {
                        rang = (bottom: bottom, top: top)
                    }
                }
            }
        }
        self.range = rang
        parseCookies()
        _queryParameters = try parseURLQuery(url: originalPath)
        parseEncoding()

        if self.method == .post && !body.isEmpty {
            try parsePostRequest()
        }
    }
    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    /// Constructs request
    ///
    /// - Parameter socket: Socket
    /// - Throws: Request errors
    public convenience init(socket: Socket) throws {
        let socketBuffer = try SocketBuffer(socket: socket)
        try self.init(remoteHostname: socket.remoteHostname, buffer: socketBuffer)
    }

    // For testing purposes
    convenience init(remoteHostname: String, data: Data) throws {
        try self.init(remoteHostname: remoteHostname, buffer: StaticBuffer(buffer: data))
    }

    private func parseURLQuery(url: String) throws -> [String: String] {
        let splits = url.split(separator: "?", maxSplits: 1)
        guard splits.count == 2 else {
            return [:]
        }
        return try parseURLQuery(query: splits.last!.description)
    }

    private func parseURLQuery(query: String) throws -> [String: String] {
        var res = [String: String]()
        var arrIndexing = [String: Int]()
        for qs in query.components(separatedBy: "&") {
            let values = qs.split(separator: "=", maxSplits: 1)

            var key = qs.components(separatedBy: "=").first!
            var value: String
            if values.count == 2 {
                value = qs.components(separatedBy: "=").last!
                value = value.replacingOccurrences(of: "+", with: " ")
                if key.hasSuffix("[]") {
                    let indexKey = key
                    if arrIndexing[indexKey] == nil {
                        arrIndexing[indexKey] = 0
                    }
                    let index = arrIndexing[indexKey]!
                    _ = key.removeLast()
                    key += "\(index)]"
                    arrIndexing[indexKey] = index + 1
                }
            } else {
                value = ""
            }

            guard let finalValue = value.removingPercentEncoding else {
                throw RequestError(kind: .postBodyParseError(errorString: value))
            }
            res[key] = finalValue
        }
        return res
    }

    private func parseEncoding() {
        guard var acceptLine = headers[.acceptEncoding] else {
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
        guard let cookieLine = headers[.cookie] else {
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
        guard let contentType = headers[.contentType] else {
            throw HTTPError(
                status: .unsupportedMediaType,
                description: "Missing \(HTTPHeaderKey.contentType)")
        }
        let lowercasedType = contentType.lowercased()
        if lowercasedType.hasPrefix(HTTPHeader.ContentType.formUrlencoded.description) {
            try parseURLEncoded()
        } else if lowercasedType.hasPrefix(HTTPHeader.ContentType.formData.description) {
            try parseMultipart(contentType: contentType)
        }
        // TODO JSON
    }

    private func parseMultipart(contentType: String) throws {
        let CRLF = Data(bytes: [0xD, 0xA])
        let parts = contentType.components(separatedBy: "boundary=")
        guard parts.count == 2 else {
            throw RequestError(kind: .postBodyParseError(errorString: "No boundary"))
        }
        let boundary = "--\(parts[1])"
        guard let boundaryData = boundary.data(using: .utf8) else {
            throw RequestError(kind: .headParseError)
        }
        var buffer = StaticBuffer(buffer: body)
        guard (try buffer.read(until: boundaryData, allowEmpty: true)).isEmpty else {
            throw RequestError(kind: .postBodyParseError(errorString: "Wrong format"))
        }
        let end = CRLF + boundaryData
        var working = true
        while working {
            // swiftlint:disable:next force_try
            let pom = try! buffer.read(bytes: 2)
            if pom == CRLF {
                let (name, fileName) = try parseMultipartLine(buffer: &buffer)
                // swiftlint:disable:next force_try
                _ = try! buffer.read(bytes: 2)
                let body = try buffer.read(until: end, allowEmpty: false)
                self.postMultipart[name] = Multipart(name: name, fileName: fileName, content: body)
            } else if pom == Data(bytes: [0x2D, 0x2D]) {
                working = false
            }
        }
    }

    private func parseMultipartLine(buffer: inout StaticBuffer)
        throws -> (name: String, fileName: String?) {
            let line = try buffer.readString(until: .crlf)
            let contentDisposition = line.split(separator: ":", maxSplits: 1)
            guard contentDisposition.first!.lowercased() == "content-disposition" else {
                throw RequestError(
                    kind: .postBodyParseError(errorString: "missing content-disposition"))
            }
            var name: String? = nil
            var fileName: String? = nil
            String(contentDisposition.last!).components(separatedBy: ";").forEach { valueString in
                let value: String
                if valueString.first == " " {
                    value = String(valueString.dropFirst())
                } else {
                    value = valueString
                }
                let attribute = value.split(separator: "=", maxSplits: 1)
                guard attribute.count == 2
                    && attribute.last!.first == "\""
                    && attribute.last!.last == "\"" else {
                        return
                }
                let start = attribute.last!.index(after: attribute.last!.startIndex)
                let end = attribute.last!.index(before: attribute.last!.endIndex)
                let attributeValue = String(attribute.last![start..<end])
                switch attribute.first! {
                case "name":
                    name = attributeValue
                case "filename":
                    fileName = attributeValue
                default:
                    break
                }
            }

            guard name != nil else {
                throw RequestError(
                    kind: .postBodyParseError(errorString: "Missing 'name' in Content-Disposition"))
            }
            return (name!, fileName)
    }

    private func parseURLEncoded() throws {
        let data = body
        guard let query = String(data: data, encoding: .utf8) else {
            throw DataError(kind: .dataEncodingError)
        }
        _postParameters = try parseURLQuery(query: query)
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
    /// Query parameters are after '?' in url for example in
    ///
    ///     "http://localhost/posts?name=Leo&age=21"
    ///
    /// are query parameters *name* with value 'Leo' and *age* with value '21'
    ///
    /// - Parameter key: Parameter name
    /// - Returns: Parameter value
    public func getQueryParameter(for key: String) -> String? {
        return _queryParameters[key]
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
    public var queryParameters: [String: String?] {
        return _queryParameters
    }
}

// MARK: - Session control
extension Request {
    /// Get new session
    ///
    /// - Returns: New session
    /// - Throws: `SessionError(kind: .cantEstablish)`
    @discardableResult
    public func newSession() throws -> Session {
        guard let new = sessionBuilder.new(for: self) else {
            throw SessionError(kind: .cantEstablish)
        }
        new._isNew = true
        _session = new
        return new
    }

    /// Get current session
    ///
    /// - Returns: Current session
    /// - Throws: `SessionError(kind: .missingSession)` if there is no session
    public func session() throws -> Session {
        guard let sess = _session else {
            throw SessionError(kind: .missingSession)
        }
        return sess
    }

    /// Returns true if session exists
    public var sessionExists: Bool {
        return _session != nil
    }

    func setSession(_ session: Session) {
        _session = session
    }
}

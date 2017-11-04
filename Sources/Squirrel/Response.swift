//
//  Response.swift
//  Squirrel
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation
import PathKit
import GZip
import SquirrelCore

/// Responder
public typealias AnyResponseHandler = ((Request) throws -> Any)

/// Response class
open class Response {

    private let routeTree = RouteTree()

    /// Response status
    public let status: HTTPStatus

    private let httpProtocolVersion = "HTTP/1.1"

    var contentEncoding: HTTPHeader.Encoding? = nil

    /// Cookies
    public var cookies: [String: String] = [:]

    public var headers = HTTPHead()

    private var body = Data()

    /// Body length
    var bodyLength: Int {
        return body.count
    }

    /// Construct response with HTTP status
    ///
    /// - Parameter status: HTTP Status
    public init(status: HTTPStatus) {
        self.status = status
        setHeader(to: .contentType(.plain))

        if let location = getLocationFor(status: status) {
            setHeader(to: .location(location: location))
        }

        switch status {
        case .unauthorized(let wwwAuthenticate):
            setHeader(for: .wwwAuthenticate, to: wwwAuthenticate)
        case .tooManyRequests(let retryAfter),
             .serviceUnavailable(let retryAfter):
            setHeader(for: .retryAfter, to: retryAfter)
        case .notAllowed(let allowed):
            let value = allowed.map { $0.rawValue }.joined(separator: ", ")
            setHeader(for: .allow, to: value)
        default:
            break
        }
    }

   /// Construct response with HTTP status, headers and body
   ///
   /// - Parameters:
   ///   - status: HTTP Status
   ///   - headers: HTTP Headers
   ///   - body: HTTP Body
   public convenience init(status: HTTPStatus = .ok, headers: [String: String] = [:], body: Data) {
        self.init(status: status)

        self.body = body
        for (key, value) in headers {
            self.headers[key] = value
        }
    }

    /// Construct response with HTTP status, headers and body
    ///
    /// - Parameters:
    ///   - status: HTTP Status
    ///   - headers: HTTP Headers
    ///   - body: HTTP Body
    public convenience init(status: HTTPStatus = .ok, headers: Set<HTTPHeader>, body: Data) {
        var hds = [String: String]()
        for header in headers {
            let (key, value) = header.keyValue
            hds[key] = value
        }
        self.init(status: status, headers: hds, body: body)
    }

    private func getLocationFor(status: HTTPStatus) -> String? {
        switch status {
        case .created(let location),
             .movedPermanently(let location),
             .found(let location),
             .seeOther(let location),
             .temporaryRedirect(let location),
             .permanentRedirect(let location):

            return location.description
        default:
            return nil
        }
    }

    /// Set HTTP Header
    ///
    /// - Parameters:
    ///   - key: Header Key
    ///   - value: Header Value
    @available(*, deprecated: 0.3.1, message: "Use headers directly")
    public func setHeader(for key: String, to value: String) {
        headers[key] = value
    }

    /// Set HTTP Header
    ///
    /// - Parameters:
    ///   - key: Header Key
    ///   - value: Header Value
    @available(*, deprecated: 0.3.1, message: "Use headers directly")
    public func setHeader(for key: HTTPHeaderKey, to value: String) {
        setHeader(for: key.description, to: value)
    }

    /// Set HTTP Header
    ///
    /// - Parameter keyValue: Header
    @available(*, deprecated: 0.3.1, message:"Use headers directly")
    public func setHeader(to keyValue: HTTPHeader) {
        let (key, value) = keyValue.keyValue
        setHeader(for: key, to: value)
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length

    /// Construct from file
    ///
    /// - Parameter path: File path
    /// - Throws: `HTTPError`
    public init(pathToFile path: Path) throws {

        status = .ok

        guard path.exists else {
            throw HTTPError(status: .notFound, description: "Path does not exists.")
        }

        guard path.isFile else {
            throw HTTPError(status: .notFound, description: "File not found")
        }
        body = try path.read()

        if let fileExtension = path.`extension` {
            switch fileExtension.lowercased() {
            case "json":
                setHeader(to: .contentType(.json))
            case "js":
                setHeader(to: .contentType(.js))

            case "jpg", "jpeg":
                setHeader(to: .contentType(.jpeg))
            case "png":
                setHeader(to: .contentType(.png))
            case "svg":
                setHeader(to: .contentType(.svg))

            case "css":
                setHeader(to: .contentType(.css))
            case "html":
                setHeader(to: .contentType(.html))
            case "txt":
                setHeader(to: .contentType(.plain))

            case "mp4":
                setHeader(to: .contentType(.mp4))
                headers[.acceptRanges] = "bytes"
            case "ogg":
                setHeader(to: .contentType(.ogg))
                headers[.acceptRanges] = "bytes"
            case "mov", "gt":
                setHeader(to: .contentType(.mov))
                headers[.acceptRanges] = "bytes"
            case "webm":
                setHeader(to: .contentType(.webm))
                headers[.acceptRanges] = "bytes"
            case "avi":
                setHeader(to: .contentType(.avi))
                headers[.acceptRanges] = "bytes"
            case "wmv":
                setHeader(to: .contentType(.wmv))
                headers[.acceptRanges] = "bytes"


            default:
                setHeader(to: .contentType(.plain))
            }
        } else {
            // TODO Binary data
            setHeader(to: .contentType(.plain))
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

    func responeHandler() -> (Request) -> Response {
        return {
            _ in
            return self
        }
    }
}

// MARK: - Raw head and body
extension Response {
    var rawPartialHeader: Data {
        var header = httpProtocolVersion + " " + HTTPStatus.partialContent.description + "\r\n"

        for (key, value) in headers {
            header += key + ": " + value + "\r\n"
        }

        header += "\r\n"
        return header.data(using: .utf8)!
    }

    var rawHeader: Data {
        var header = httpProtocolVersion + " " + status.description + "\r\n"
        header += HTTPHeader.contentLength(size: bodyLength).description + "\r\n"
        if let encoding = contentEncoding {
            header += HTTPHeader.contentEncoding(encoding).description + "\r\n"
        }

        for (key, value) in headers {
            header += key + ": " + value + "\r\n"
        }
        for (key, value) in cookies {
            header += "\(HTTPHeaderKey.setCookie): \(key)=\(value)\r\n"
        }
        header += "\r\n"
        return header.data(using: .utf8)!
    }

    var rawBody: Data {
        return body
    }

    var gzippedBody: Data {
        return try! body.gzipped()
    }
}

// MARK: - Parsing response
public extension Response {
    /// Parse any to response
    ///
    /// - Parameter any: Something waht do you want to return as response
    /// - Returns: Response representation of given `any`
    /// - Throws: Response initialize errors
    public static func parseAnyResponse(any: Any) throws -> Response {
        switch any {
        case let response as Response:
            return response
        case let string as String:
            return try Response(html: string)
        case let presentable as SquirrelPresentable:
            return try Response(presentable: presentable)
        default:
            return try Response(object: any)
        }
    }
}

//
//  Response.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation
import PathKit
import GZip

typealias ResponseHandler = ((Request) -> Response)

typealias AnyResponseHandler = ((Request) throws -> Any)

/// Response class
open class Response {

    private let routeTree = RouteTree()

    private let status: HTTPStatus

    private let httpProtocolVersion = "HTTP/1.1"

    var contentEncoding: HTTPHeaders.Encoding.EncodingType? = nil

    private var headers: [String: String] = [
        HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.plain.rawValue
    ]

    private var body = Data() {
        didSet {
            finalBody = nil
        }
    }

    private var finalBody: Data? = nil

    /// Body length
    var bodyLength: Int {
        if finalBody == nil {
            finalBody = body
        }
        return Array<UInt8>(finalBody!).count
    }

    /// Construct response with HTTP status
    ///
    /// - Parameter status: HTTP Status
    public init(status: HTTPStatus) {
        self.status = status

        if let location = getLocationFor(status: status) {
            headers[HTTPHeaders.location] = location
        }

        switch status {
        case .unauthorized(let wwwAuthenticate):
            headers[HTTPHeaders.wwwAuthenticate] = wwwAuthenticate
        case .tooManyRequests(let retryAfter),
             .serviceUnavailable(let retryAfter):
            headers[HTTPHeaders.retryAfter] = retryAfter
        case .notAllowed(let allowed):
            let value = allowed.flatMap({ $0.rawValue.uppercased() }).joined(separator: ", ")
            headers[HTTPHeaders.allow] = value
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
    public func setHeader(for key: String, to value: String) {
        headers[key] = value
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
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Application.json.rawValue
                )
            case "js":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Application.js.rawValue)

            case "jpg", "jpeg":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Image.jpeg.rawValue)
            case "png":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Image.png.rawValue)
            case "svg":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Image.svg.rawValue)

            case "css":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Text.css.rawValue)
            case "html":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Text.html.rawValue)
            case "txt":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Text.plain.rawValue)
            default:
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Text.plain.rawValue)
            }
        } else {
            // TODO Binary data
            setHeader(
                for: HTTPHeaders.ContentType.contentType,
                to: HTTPHeaders.ContentType.Text.plain.rawValue)
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

    func responeHandler() -> ResponseHandler {
        return {
            _ in
            return self
        }
    }
}

// MARK: - Raw head and body
extension Response {
    var rawHeader: Data {
        if finalBody == nil {
            finalBody = rawBody
        }
        var header = httpProtocolVersion + " " + status.description + "\r\n"
        header += HTTPHeaders.contentLength + ": " + String(bodyLength) + "\r\n"
        if let encoding = contentEncoding {
            header += HTTPHeaders.Encoding.contentEncoding + ": "
                + encoding.rawValue + "\r\n"
        }
        for (key, value) in headers {
            header += key + ": " + value + "\r\n"
        }
        header += "\r\n"
        return header.data(using: .utf8)!
    }

    var rawBody: Data {
        if let final = finalBody {
            return final
        }
        let res: Data
        if contentEncoding != nil {
            // swiftlint:disable:next force_try
            res = try! body.gzipped()
        } else {
            res = body
        }
        finalBody = res
        return res
    }
}

//
//  Response.swift
//  Squirrel
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation
import PathKit
import SquirrelCore
import Socket

/// Responder
public typealias AnyResponseHandler = ((Request) throws -> Any)

public protocol ResponseProtocol: class {
    func send(socket: Socket)
    func sendPartial(socket: Socket, range: (bottom: UInt, top: UInt))
    var headers: HTTPHead { get set }
    var status: HTTPStatus { get }
    
//    var httpProtocolVersion: RequestLine.HTTPProtocol { get }
    
//    var contentEncoding: HTTPHeader.Encoding? { get set }
    
}

public extension ResponseProtocol {
    func setCookie(_ name: String, to value: String) {
        headers.cookies[name] = value
    }
    
    func cookie(for name: String) -> String? {
        return headers.cookies[name]
    }
}

// TODO rename to Response
/// Response class
open class Response: ResponseProtocol {

    /// Response status
    public let status: HTTPStatus

    private let httpVersion = RequestLine.HTTPProtocol.http11

    var contentEncoding: HTTPHeader.Encoding? = nil

    /// HTTP head
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
        headers.set(to: .contentType(.plain))

        if let location = getLocationFor(status: status) {
            headers.set(to: .location(location: location))
        }

        switch status {
        case .unauthorized(let wwwAuthenticate):
            headers[.wwwAuthenticate] = wwwAuthenticate
        case .tooManyRequests(let retryAfter),
             .serviceUnavailable(let retryAfter):
            headers[.retryAfter] = retryAfter
        case .notAllowed(let allowed):
            let value = allowed.map { $0.rawValue }.joined(separator: ", ")
            headers[.allow] = value
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
                headers.set(to: .contentType(.json))
            case "js":
                headers.set(to: .contentType(.js))

            case "jpg", "jpeg":
                headers.set(to: .contentType(.jpeg))
            case "png":
                headers.set(to: .contentType(.png))
            case "svg":
                headers.set(to: .contentType(.svg))

            case "css":
                headers.set(to: .contentType(.css))
            case "html":
                headers.set(to: .contentType(.html))
            case "txt":
                headers.set(to: .contentType(.plain))

            case "mp4":
                headers.set(to: .contentType(.mp4))
                headers[.acceptRanges] = "bytes"
            case "ogg":
                headers.set(to: .contentType(.ogg))
                headers[.acceptRanges] = "bytes"
            case "mov", "gt":
                headers.set(to: .contentType(.mov))
                headers[.acceptRanges] = "bytes"
            case "webm":
                headers.set(to: .contentType(.webm))
                headers[.acceptRanges] = "bytes"
            case "avi":
                headers.set(to: .contentType(.avi))
                headers[.acceptRanges] = "bytes"
            case "wmv":
                headers.set(to: .contentType(.wmv))
                headers[.acceptRanges] = "bytes"


            default:
                headers.set(to: .contentType(.plain))
            }
        } else {
            // TODO Binary data
            headers.set(to: .contentType(.plain))
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
}

// MARK: - Raw head and body
extension Response {
    @available(*, unavailable, message: "use headers.makeHeader(_:_:)")
    var rawPartialHeader: Data {
        var header = httpVersion.rawValue + " " + HTTPStatus.partialContent.description + "\r\n"

        for (key, value) in headers {
            header += key + ": " + value + "\r\n"
        }

        header += "\r\n"
        return header.data(using: .utf8)!
    }

    // TODO remove
    @available(*, unavailable, message: "use body")
    var rawBody: Data {
        return body
    }
}

/// Parse any to response
///
/// - Parameter any: Something waht do you want to return as response
/// - Returns: Response representation of given `any`
/// - Throws: Response initialize errors
public func parseAnyResponse(any: Any) throws -> ResponseProtocol {
    switch any {
    case let response as ResponseProtocol:
        return response
    case let string as String:
        return try Response(html: string)
    case let presentable as SquirrelPresentable:
        return try Response(presentable: presentable)
    default:
        return try Response(object: any)
    }
}

// MARK: - Sending data
public extension Response {
    func sendPartial(socket: Socket, range: (bottom: UInt, top: UInt)) {
        log.verbose("Sending partial \(range.bottom) \(range.top)")
        let top: UInt
        if range.top < bodyLength {
            top = range.top
        } else {
            top = UInt(bodyLength - 1)
        }
        let bottom: UInt
        if range.bottom <= top {
            bottom = range.bottom
        } else {
            bottom = top
        }
        let data = body[bottom..<top + 1]
        headers[.connection] = "keep-alive"
        headers[.acceptRanges] = nil
        headers.set(to: .contentRange(
            start: bottom,
            end: top,
            from: UInt(bodyLength)))
        
        let size = data.count
        headers.set(to: .contentLength(size: size))
        
        let head = headers.makeHeader(httpVersion: httpVersion, status: .partialContent)
        _ = try? socket.write(from: head)
        _ = try? socket.write(from: data)
    }
    
    func send(socket: Socket) {
        log.verbose("Sending response")
        headers.set(to: .contentLength(size: bodyLength))
        let head = headers.makeHeader(httpVersion: httpVersion, status: status)
        _ = try? socket.write(from: head)
        _ = try? socket.write(from: body)
    }
}

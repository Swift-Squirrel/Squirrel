//
//  StreamResponse.swift
//  Squirrel
//
//  Created by Filip Klembara on 4/5/18.
//

import Foundation
import Socket

/// Streamer
public typealias Streamer = (WriteSocket) throws -> Void

/// Protocol for writing to socket in stream
public protocol WriteSocket {
    func send(_ data: Data) throws
    func send(_ string: String) throws
}

/// Response with stream
open class StreamResponse: ResponseProtocol {
    /// HTTP headers
    public var headers = HTTPHeader()

    /// HTTP status
    public let status: HTTPStatus

    private let streamer: Streamer

    private let httpVersion = RequestLine.HTTPProtocol.http11

    /// Inits stream response
    ///
    /// - Parameters:
    ///   - status: HTTP status
    ///   - contentType: Content type (default nil) (if not nil, overrides content type in header)
    ///   - header: HTTP header
    ///   - streamClosure: Closure where you can stream data to client
    public init(status: HTTPStatus = .ok,
                contentType: HTTPHeaderElement.ContentType? = nil,
                header: HTTPHeader,
                streamClosure: @escaping Streamer) {

        self.headers = header
        if let contType = contentType {
            self.headers.set(to: .contentType(contType))
        }
        self.streamer = streamClosure
        self.status = status

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

    /// Inits stream response
    ///
    /// - Parameters:
    ///   - status: HTTP status
    ///   - contentType: Content type (default nil) (if not nil, overrides content type in header)
    ///   - header: HTTP header
    ///   - streamClosure: Closure where you can stream data to client
    public convenience init(status: HTTPStatus = .ok,
                            contentType: HTTPHeaderElement.ContentType? = nil,
                            headers: [String: String] = [:],
                            streamClosure: @escaping Streamer) {

        self.init(status: status, contentType: contentType,
                  headers: headers, streamClosure: streamClosure)
    }

    /// Send data to client in stream
    ///
    /// - Note:
    ///   Overrides HTTP transferEncoding to `chunked`
    ///
    /// - Parameter socket: Socket
    public func send(socket: Socket) {
        log.verbose("stream")
        let stream = SocketStream(socket: socket)
        headers[.transferEncoding] = "chunked"
        let headerData = headers.makeHeader(httpVersion: httpVersion, status: status)
        try? stream.open(header: headerData)
        try? streamer(stream)
        try? stream.close()
    }

    /// Sends partial response to client
    ///
    /// - Parameters:
    ///   - socket: Socket
    ///   - range: Range
    public func sendPartial(socket: Socket, range: (bottom: UInt, top: UInt)) {
        log.verbose("stream partial \(range.bottom)...\(range.top)")

        let stream = PartialSocketStream(socket: socket, bottom: range.bottom, top: range.top)
        try? streamer(stream)
        headers[.connection] = "keep-alive"
        headers[.acceptRanges] = nil
        headers.set(to: .contentRange(
            start: stream.bottom,
            end: stream.top,
            from: stream.totalDataCount))
        headers.set(to: .contentLength(size: stream.size))

        let header = headers.makeHeader(httpVersion: httpVersion, status: .partialContent)
        try? stream.close(withHeader: header)
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
}

extension StreamResponse {
    private class SocketStream: WriteSocket {
        func send(_ string: String) throws {
            guard let data = string.data(using: .utf8) else {
                throw DataError(kind: .dataCodingError(string: string))
            }
            try send(data)
        }

        private static let CRLF = "\r\n".data(using: .utf8)!
        private let socket: Socket
        init(socket: Socket) {
            self.socket = socket
        }

        func open(header: Data) throws {
            try socket.write(from: header)
        }

        func close() throws {
            _ = try? socket.write(from: "0".data(using: .utf8)!
                + SocketStream.CRLF + SocketStream.CRLF)
        }

        func send(_ data: Data) throws {
            let sendingData = String(format: "%X", data.count).data(using: .utf8)!
                + SocketStream.CRLF + data + SocketStream.CRLF
            _ = try socket.write(from: sendingData)
        }
    }

    private class PartialSocketStream: WriteSocket {
        private let socket: Socket
        private let startIndex: UInt
        private var index: Int
        private var count: Int
        var top: UInt {
            return UInt(index + count - 1)
        }
        var bottom: UInt {
            return startIndex
        }
        private var currentIndex: Int
        private var buffer: Data
        private var sent: Bool
        var totalDataCount: UInt {
            return UInt(currentIndex)
        }
        var size: Int {
            return buffer.count
        }

        init(socket: Socket, bottom: UInt, top: UInt) {
            if bottom > top {
                startIndex = top
                self.index = Int(startIndex)
                self.count = 0
            } else {
                startIndex = bottom
                self.index = Int(startIndex)
                self.count = Int(top - bottom + 1)
            }
            self.socket = socket
            currentIndex = 0
            buffer = Data()
            sent = false
        }

        func send(_ string: String) throws {
            guard let data = string.data(using: .utf8) else {
                throw DataError(kind: .dataCodingError(string: string))
            }
            try send(data)
        }

        func send(_ data: Data) throws {
            guard !sent else {
                currentIndex += data.count
                return
            }
            guard currentIndex <= index && currentIndex + data.count > index else {
                currentIndex += data.count
                return
            }
            let validDataCount = currentIndex + data.count - index
            let bottomDataIndex = index - currentIndex + data.startIndex
            let topDataIndex: Int
            if bottomDataIndex + count > data.count {
                topDataIndex = bottomDataIndex + validDataCount
            } else {
                topDataIndex = bottomDataIndex + count
            }
            let validData = data[bottomDataIndex..<topDataIndex]
            count -= validData.count
            buffer.append(validData)
            index = topDataIndex
            currentIndex = topDataIndex
            if count == 0 {
                sent = true
                currentIndex = bottomDataIndex + data.count
            }
        }

        func close(withHeader header: Data) throws {
            try socket.write(from: header)
            try socket.write(from: buffer)
        }
    }
}

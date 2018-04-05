//
//  StreamResponse.swift
//  Squirrel
//
//  Created by Filip Klembara on 4/5/18.
//

import Foundation
import Socket

public typealias Streamer = (WriteSocket) throws -> Void

public protocol WriteSocket {
    func send(_ data: Data) throws
}
open class StreamResponse: ResponseProtocol {
    public var headers = HTTPHead()
    
    public let status: HTTPStatus
    
    private let streamer: Streamer
    
    private let httpVersion = RequestLine.HTTPProtocol.http11

    public init(status: HTTPStatus = .ok, contentType: HTTPHeader.ContentType? = nil, header: HTTPHead, streamClosure: @escaping Streamer) {
        self.headers = header
        if let contType = contentType {
            self.headers.set(to: .contentType(contType))
        }
        self.streamer = streamClosure
        self.status = status
    }

    public convenience init(status: HTTPStatus = .ok, contentType: HTTPHeader.ContentType? = nil, headers: [String: String] = [:], streamClosure: @escaping Streamer) {
        self.init(status: status, contentType: contentType, headers: headers, streamClosure: streamClosure)
    }
    
    public func send(socket: Socket) {
        log.verbose("stream")
        let stream = SocketStream(socket: socket)
        headers[.transferEncoding] = "chunked"
        let headerData = headers.makeHeader(httpVersion: httpVersion, status: status)
        try? stream.open(header: headerData)
        try? streamer(stream)
        try? stream.close()
    }
    
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
}

extension StreamResponse {
    private class SocketStream: WriteSocket {
        private static let CRLF = "\r\n".data(using: .utf8)!
        private let socket: Socket
        init(socket: Socket) {
            self.socket = socket
        }
        
        func open(header: Data) throws {
            try socket.write(from: header)
        }
        
        func close() throws {
            _ = try? socket.write(from: "0".data(using: .utf8)! + SocketStream.CRLF + SocketStream.CRLF)
        }
        
        func send(_ data: Data) throws {
            let sendingData = String(format: "%X", data.count).data(using: .utf8)! + SocketStream.CRLF
                + data + SocketStream.CRLF
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

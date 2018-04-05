//
//  StreamResponse.swift
//  Squirrel
//
//  Created by Filip Klembara on 4/5/18.
//

import Foundation
import Socket

typealias Streamer = (WriteSocket) throws -> Void

protocol WriteSocket {
    func send(_ data: Data) throws
}
open class StreamResponse: ResponseProtocol {
    public var headers = HTTPHead()
    
    public let status: HTTPStatus
    
    private let streamer: Streamer
    
    private let httpVersion = RequestLine.HTTPProtocol.http11
    
    init(status: HTTPStatus, headers: [String: String] = [:], streamClosure: @escaping Streamer) {
        self.status = status
        streamer = streamClosure
        headers.forEach { (key, value) in
            self.headers[key] = value
        }
    }
    
    public func send(socket: Socket) {
        let stream = SocketStream(socket: socket)
        headers[.transferEncoding] = "chunked"
        let headerData = headers.makeHeader(httpVersion: httpVersion, status: status)
        try? stream.open(header: headerData)
        try? streamer(stream)
        try? stream.close()
    }
    
    public func sendPartial(socket: Socket, range: (bottom: UInt, top: UInt)) {
        let stream = PartialSocketStream(socket: socket, bottom: range.bottom, top: range.top)
        try? streamer(stream)
        
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
        private let index: Int
        private let count: Int
        private var currentIndex: Int
        private var buffer: Data
        private var sent: Bool
        
        init(socket: Socket, bottom: UInt, top: UInt) {
            self.socket = socket
            self.index = Int(bottom)
            self.count = Int(top - bottom)
            currentIndex = 0
            buffer = Data()
            sent = false
        }
        
        func send(_ data: Data) throws {
            guard !sent else {
                return
            }
            defer {
                currentIndex += data.count
            }
            guard currentIndex + data.count >= index else {
                return
            }
            guard currentIndex < index + count else {
                return
            }
            
            
        }
    }
}

/*
private func sendChunked(socket: Socket, head: Data, body: Data) {
    headers[.transferEncoding] = "chunked"
    var c = body.count
    var i = 0
    let _ = try? socket.write(from: head)
    let chunkSize = 2048

    while c >= chunkSize {
        let d = body[(i*chunkSize)..<(chunkSize*(i+1))]
        var d1: Data = (String(format: "%X", d.count) + "\r\n").data(using: .utf8)!
        d1.append(contentsOf: d)
        d1.append("\r\n".data(using: .utf8)!)

        let _ = try? socket.write(from: d1)
        c -= chunkSize
        i += 1
    }
    if c > 0 {
        let d = body[(body.count - c)..<(body.count)]
        var d1: Data = (String(format: "%X", c) + "\r\n").data(using: .utf8)!
        d1.append(contentsOf: d)
        d1.append("\r\n".data(using: .utf8)!)

        _ = try? socket.write(from: d1)
    }
    _ = try? socket.write(from: "0\r\n\r\n".data(using: .utf8)!)
}
*/

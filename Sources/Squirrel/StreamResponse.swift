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
    
    struct SocketStream: WriteSocket {
        let socket: Socket
        init(socket: Socket) {
            self.socket = socket
        }
        func send(_ data: Data) throws {
            try socket.write(from: data)
        }
    }
    
    public var headers = HTTPHead()
    
    public let status: HTTPStatus
    
    public var cookies = [String: String]()
    
    private let streamer: Streamer
    
    init(status: HTTPStatus, streamClosure: @escaping Streamer) {
        self.status = status
        streamer = streamClosure
    }
    
    
    public func send(socket: Socket) {
        
    }
    
    public func sendPartial(socket: Socket, range: (bottom: UInt, top: UInt)) {
        
    }
}

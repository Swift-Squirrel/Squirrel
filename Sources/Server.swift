//
//  Server.swift
//  micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

#if os(Linux)
    import Glibc
#else
    import Darwin
#endif

import Foundation
import Socket
import Dispatch

class Server {
    
    private let port: UInt16
    let bufferSize = 2048
    var listenSocket: Socket? = nil
    var connected = [Int32: Socket]()
    var acceptNewConnection = true
    
    init(port: UInt16) {
        self.port = port
    }
    
    deinit {
        for socket in connected.values {
            socket.close()
        }
        listenSocket?.close()
    }
    
    func run() throws {
        //Using the following create class method:
        //public class func create(family: ProtocolFamily = .inet, type: SocketType = .stream, proto: SocketProtocol = .tcp) throws -> Socket
        let socket = try Socket.create()
        
        
        listenSocket = socket
        try socket.listen(on: Int(port))
        print("Listening port: \(socket.listeningPort)")
        let queue = DispatchQueue(label: "clientQueue", attributes: .concurrent)
        repeat {
            let connectedSocket = try socket.acceptClientConnection()
            
            print("Connection from: \(connectedSocket.remoteHostname)")
            queue.async{self.newConnection(socket: connectedSocket)}
        } while acceptNewConnection

    }
    func newConnection(socket: Socket) {
        connected[socket.socketfd] = socket
        
//        var cont = true
        var dataRead = Data(capacity: bufferSize)
        var cont = true
        repeat {
            do {
                let bytes = try socket.read(into: &dataRead)
                if bytes > 0 {
                   
                    if let readStr = String(data: dataRead, encoding: .utf8) {
                        
                        print("Received: \(readStr)")
                        
                        dataRead.count = 0
                    }
                }
            } catch let error {
                print("error: \(error)")
            }
        } while cont
        connected.removeValue(forKey: socket.socketfd)
        socket.close()
    }

    
}

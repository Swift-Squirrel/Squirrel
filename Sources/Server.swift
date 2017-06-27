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
    let bufferSize = 20
    var listenSocket: Socket? = nil
    var connected = [Int32: Socket]()
    var acceptNewConnection = true
    let serverRoot: String
    
    init(port: UInt16 = Config.sibling.port, serverRoot root: String = Config.sibling.serverRoot) {
        self.port = port
        self.serverRoot = root
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
        var zeroTimes = 100
        repeat {
            do {
                let bytes = try socket.read(into: &dataRead)
                if bytes > 0 {
                    zeroTimes = 100
                    do {
                        let request = try Request(data: dataRead)
                        if (request.getHeader(for: "Connection") != nil) && request.getHeader(for: "Connection") != "keep-alive" {
                            cont = false
                        }
                        
                        if let handler = ResponseManager.findHandler(for: request) {
                            let response = handler(request)
                            try socket.write(from: response.raw())
                        } else {
                            var p = Config.sibling.webRoot + request.path
                            var isDir: ObjCBool = false
                            if !FileManager.default.fileExists(atPath: p, isDirectory: &isDir) {
                                // 404
                            } else if isDir.boolValue == false {
                                guard let filePath = URL(string: Config.sibling.webRoot + request.path) else {
                                    throw e.unknownError
                                }
                                let fileExtension = filePath.pathExtension
                                
                                switch fileExtension.lowercased() {
                                case HTTPHeaders.ContentType.Image.jpeg.rawValue:
                                    break
                                case HTTPHeaders.ContentType.Image.png.rawValue:
                                    break
                                case HTTPHeaders.ContentType.Text.html.rawValue:
                                    break
                                case HTTPHeaders.ContentType.Text.plain.rawValue:
                                    break
                                default:
                                    throw e.unknownError
                                }
                            } else {
                                p += "index.html"
                                if FileManager.default.fileExists(atPath: p, isDirectory: &isDir) && !isDir.boolValue {
                                    guard let filePath = URL(string: p) else {
                                        throw e.unknownError
                                    }
                                    let body = try String(contentsOfFile: filePath.absoluteString)
                                    let request = Response(
                                        headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
                                        body: body
                                    )
                                    try socket.write(from: request.raw())
                                    
                                } else {
                                    // 404
                                }
                            }
                            
                        }
                    } catch is e {
                        cont = false
                        
                    }
                    dataRead.removeAll()
                } else {
                    zeroTimes -= 1
                    if(zeroTimes == 0) {
                        cont = false
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

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

    init(port: UInt16 = Config.sharedInstance.port, serverRoot root: String = Config.sharedInstance.serverRoot) {
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
        ResponseManager.sharedInstance.addRoutes()

        let socket = try Socket.create()

        listenSocket = socket
        try socket.listen(on: Int(port))
        Log.write(message: "Server is running on port \(socket.listeningPort)", logGroup: .infoImportant)
        let queue = DispatchQueue(label: "clientQueue", attributes: .concurrent)
        repeat {
            let connectedSocket = try socket.acceptClientConnection()

            Log.write(message: "Connection from: \(connectedSocket.remoteHostname)", logGroup: .info)

            queue.async {self.newConnection(socket: connectedSocket)}
        } while acceptNewConnection

    }
    func newConnection(socket: Socket) {
        connected[socket.socketfd] = socket

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
                        Log.write(message: request.method.rawValue + " " + request.path, logGroup: .infoImportant)

                        if (request.getHeader(for: "Connection") != nil) && request.getHeader(for: "Connection") != "keep-alive" {
                            cont = false
                        }

                        if let handler = ResponseManager.sharedInstance.findHandler(for: request) {
                            Log.write(message: "Using handler", logGroup: .debug)
                            let response = handler(request)
                            try socket.write(from: response.raw())
                        } else {
                            var p = Config.sharedInstance.webRoot + request.path
                            var isDir: ObjCBool = false
                            if !FileManager.default.fileExists(atPath: p, isDirectory: &isDir) {
                                Log.write(message: "404", logGroup: .debug)
                                // 404
                            } else if isDir.boolValue == false {
                                Log.write(message: "Sending file", logGroup: .debug)
                                guard let filePath = URL(string: "file://" + Config.sharedInstance.webRoot + request.path) else {
                                    throw e.unknownError
                                }
                                guard filePath.absoluteString.hasPrefix(Config.sharedInstance.webRoot) else {
                                    throw e.unknownError
                                }
                                do {
                                    let response = try Response(file: filePath)
                                    self.send(socket: socket, response: response)
                                } catch let error {
                                    Log.write(message: "\(error)", logGroup: .errors)
                                }
                            } else {
                                p += "index.html"
                                if FileManager.default.fileExists(atPath: p, isDirectory: &isDir) && !isDir.boolValue {
                                    Log.write(message: "Sending index.html", logGroup: .debug)
                                    guard let filePath = URL(string: p) else {
                                        throw e.unknownError
                                    }
                                    let body = try String(contentsOfFile: filePath.absoluteString)
                                    let request = Response(
                                        headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
                                        body: body.data(using: .utf8)!
                                    )
                                    try socket.write(from: request.raw())

                                } else {
                                    Log.write(message: "404", logGroup: .debug)
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

    private func send(socket: Socket, response: Response) {
        if response.bodyLenght <= 4096 {
            let _ = try? socket.write(from: response.raw())
        } else {
            response.setHeader(for: "Transfer-Encoding", to: "chunked")

            var bytes = [UInt8]()
            let bodyData = response.rawBody()
            bytes = Array(bodyData)

            var c = bytes.count
            var i = 0
            let _ = try? socket.write(from: response.rawHeader())

            let chunkSize = 2048

            while(c >= chunkSize) {
                let d: [UInt8] = Array(bytes[(i*chunkSize)...(chunkSize*(i+1) - 1)])
                var d1: Data = (String(format: "%X", d.count) + "\r\n").data(using: .utf8)!
                d1.append(contentsOf: d)
                d1.append("\r\n".data(using: .utf8)!)

                let _ = try? socket.write(from: d1)
                c -= chunkSize
                i += 1
            }
            if(c > 0) {
                let d: [UInt8] = Array(bytes[(bytes.count - c)...(bytes.count - 1)])
                var d1: Data = (String(format: "%X", c) + "\r\n").data(using: .utf8)!
                d1.append(contentsOf: d)
                d1.append("\r\n".data(using: .utf8)!)

                let _ = try? socket.write(from: d1)
                c = 0
            }
            let _ = try? socket.write(from: "0\r\n\r\n".data(using: .utf8)!)

        }
    }


}

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
import PathKit

class Server {

    private let port: UInt16
    let bufferSize = 20
    var listenSocket: Socket? = nil
    var connected = [Int32: Socket]()
    var acceptNewConnection = true
    let serverRoot: String

    let responsManager = ResponseManager.sharedInstance

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

                        if (request.getHeader(for: "Connection") != nil)
                            && request.getHeader(for: "Connection") != "keep-alive" {
                            cont = false
                        }
                        let handler = getHandler(for: request)
                        let handlerResult: Any
                        do {
                            handlerResult = try handler(request) // TODO
                        } catch let error {
                            handlerResult = ErrorHandler.sharedInstance.response(for: error)
                        }
                        let response = parseAnyResponse(any: handlerResult)
                        send(socket: socket, response: response)
                    } catch is MyError {
                        cont = false
                    }
                    dataRead.removeAll()
                } else {
                    zeroTimes -= 1
                    if zeroTimes == 0 {
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

    private func parseAnyResponse(any: Any) -> Response {
        switch any {
        case let response as Response:
            return response
        case let string as String:
            // TODO Response(html:)
            return Response(
                headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
                body: string.data(using: .utf16)!
            )
        default:
            // Object as JSON
            return Response(
                headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
                body: "Not implemented".data(using: .utf8)!
            )
        }
    }

    private func getHandler(for request: Request) -> AnyResponseHandler {
        if let handler = ResponseManager.sharedInstance.findHandler(for: request) {
            Log.write(message: "Using handler", logGroup: .debug)
            return handler
        }
        let path = Path(Config.sharedInstance.webRoot + request.path).normalize()

        guard path.absolute().description.hasPrefix(Config.sharedInstance.webRoot) else {
            return ErrorHandler.sharedInstance.handler(for: MyError.unknownError)
        }

        guard path.exists else {
            return ErrorHandler.sharedInstance.handler(for: MyError.unknownError)
        }

        if path.isDirectory {
            let index = Path(path.absolute().description + "/index.html")
            if index.exists {
                do {
                    return try Response(pathToFile: index).responeHandler()
                } catch let error as ResponseError {
                    return error.response.responeHandler()
                } catch let error {
                    let res = ErrorHandler.sharedInstance.handler(for: error)
                    return res
                }
            }
            guard Config.sharedInstance.isAllowedDirBrowsing else {
                return ErrorHandler.sharedInstance.handler(for: MyError.unknownError)
            }
            // TODO
            return Response(
                headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
                body: "Not implemented".data(using: .utf8)!
            ).responeHandler()
        }
        do {
            return try Response(pathToFile: path).responeHandler()
        } catch let error as ResponseError {
            return error.response.responeHandler()
        } catch let error {
            return ErrorHandler.sharedInstance.handler(for: error)
        }
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

            while c >= chunkSize {
                let d: [UInt8] = Array(bytes[(i*chunkSize)...(chunkSize*(i+1) - 1)])
                var d1: Data = (String(format: "%X", d.count) + "\r\n").data(using: .utf8)!
                d1.append(contentsOf: d)
                d1.append("\r\n".data(using: .utf8)!)

                let _ = try? socket.write(from: d1)
                c -= chunkSize
                i += 1
            }
            if c > 0 {
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

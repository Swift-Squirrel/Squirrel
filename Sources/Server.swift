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
        log.info("Server is running on port \(socket.listeningPort)")
        let queue = DispatchQueue(label: "clientQueue", attributes: .concurrent)
        repeat {
            let connectedSocket = try socket.acceptClientConnection()
            log.verbose("Connection from: \(connectedSocket.remoteHostname)")
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
                        log.info(request.method.rawValue + " " + request.path)

                        if (request.getHeader(for: "Connection") != nil)
                            && request.getHeader(for: "Connection") != "keep-alive" {
                            cont = false
                        }
                        let response = handle(request: request)
                        send(socket: socket, response: response)
                    } catch let error {
                        let response = Response(status: .internalError)
                        send(socket: socket, response: response)
                        cont = false
                        throw error
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
                cont = false
            }
        } while cont
        connected.removeValue(forKey: socket.socketfd)
        socket.close()
    }

    private func handle(request: Request) -> Response {
        do {
            let handler = try getHandler(for: request)
            let handlerResult = try handler(request)
            return try parseAnyResponse(any: handlerResult)
        } catch let error {
            return ErrorHandler.sharedInstance.response(for: error)
        }

    }

    private func parseAnyResponse(any: Any) throws -> Response {
        switch any {
        case let response as Response:
            return response
        case let string as String:
            return try Response(html: string)
        default:
            return try Response(object: any)
        }
    }

    private func getHandler(for request: Request) throws -> AnyResponseHandler {
        if let handler = try ResponseManager.sharedInstance.findHandler(for: request) {
            log.debug("Using handler")
            return handler
        }
        let path = Path(Config.sharedInstance.webRoot + request.path).normalize()

        guard path.absolute().description.hasPrefix(Config.sharedInstance.webRoot) else {
            if let handler = try ResponseManager.sharedInstance.findHandler(for: request) {
                log.debug("Using handler")
                return handler
            } else {
                throw HTTPError(status: .notFound, description: "'/' is not handled")
            }
        }

        guard path.exists else {
            throw HTTPError(status: .notFound, description: "\(request.path) is not found.")
        }

        if path.isDirectory {
            let index = Path(path.absolute().description + "/index.html")
            if index.exists {
                return try Response(pathToFile: index).responeHandler()
            }
            guard Config.sharedInstance.isAllowedDirBrowsing else {
                throw HTTPError(status: .forbidden, description: "Directory browsing is not allowed")
            }
            // TODO
            return Response(
                headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
                body: "Not implemented".data(using: .utf8)!
            ).responeHandler()
        }
        return try Response(pathToFile: path).responeHandler()
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

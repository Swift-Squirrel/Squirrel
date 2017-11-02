//
//  Server.swift
//  Squirrel
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation
import Socket
import Dispatch
import PathKit
import SquirrelConfig

/// Server class
open class Server: Router {

    private let port: UInt16
    let bufferSize = 20
    var listenSocket: Socket? = nil
    var connected = [Int32: Socket]()
    var acceptNewConnection = true
    let serverRoot: Path

    /// global middlewares used for all routes
    public let middlewareGroup: [Middleware]

    /// Construct server
    ///
    /// - Parameters:
    ///   - port: Port for HTTP requests
    ///   - root: Root directory of server
    ///   - globalMiddlewares: Middlewares used on all routes (default: [])
    public init(
        port: UInt16 = Config.sharedInstance.port,
        serverRoot root: Path = Config.sharedInstance.serverRoot,
        globalMiddlewares: [Middleware] = []) {

        self.port = port
        self.serverRoot = root
        self.middlewareGroup = globalMiddlewares

    }

    deinit {
        for socket in connected.values {
            socket.close()
        }
        listenSocket?.close()
    }

    /// Run server and start to listen on given `port` from `init(port:root:)`
    ///
    /// - Throws: Socket errors
    public func run() throws {
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
                        if request.acceptEncoding.count > 0 {
                            if request.acceptEncoding.contains(.gzip) {
                                response.contentEncoding = .gzip
                            }
                        }
                        send(socket: socket, response: response)
                    } catch let error {
                        let response = ErrorHandler.sharedInstance.response(for: error)
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
                log.error("error: \(error)")
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
            return try Response.parseAnyResponse(any: handlerResult)
        } catch let error {
            return ErrorHandler.sharedInstance.response(for: error)
        }

    }

    private func getHandler(for request: Request) throws -> AnyResponseHandler {
        if let handler = try ResponseManager.sharedInstance.findHandler(for: request) {
            log.debug("Using handler")
            return handler
        }
        let path: Path

        if (Config.sharedInstance.webRoot + "Storage").isSymlink
            && Path(request.path.lowercased()).normalize().starts(with: ["storage"]) {

            var a = Path(request.path).normalize().string.split(separator: "/")
            a.removeFirst()
            path = (Config.sharedInstance.publicStorage + a.joined(separator: "/")).normalize()
        } else {
            let requestPath = String(request.path.dropFirst())
            path = (Config.sharedInstance.webRoot + requestPath).normalize()

            guard path.absolute().description.hasPrefix(Config.sharedInstance.webRoot.string) else {
                if let handler = try ResponseManager.sharedInstance.findHandler(for: request) {
                    log.debug("Using handler")
                    return handler
                } else {
                    throw HTTPError(status: .notFound, description: "'/' is not handled")
                }
            }
        }
        guard path.exists else {
            throw HTTPError(status: .notFound, description: "\(request.path) is not found.")
        }

        if path.isDirectory {
            let index = path + "index.html"
            if index.exists {
                return chain(middlewares: middlewareGroup, handler: { _ in
                    return try Response(pathToFile: index).responeHandler()
                })
            }
            guard Config.sharedInstance.isAllowedDirBrowsing else {
                throw HTTPError(
                    status: .forbidden,
                    description: "Directory browsing is not allowed")
            }

            // TODO Directory browsing
            return chain(middlewares: middlewareGroup, handler: { _ in
                return Response(
                    headers: [.contentType(.html)],
                    body: "Not implemented".data(using: .utf8)!
                )
            })
        }
        return chain(middlewares: middlewareGroup, handler: { _ in
            return try Response(pathToFile: path)
        })
    }

    private func send(socket: Socket, response: Response) {
        let body = response.rawBody
        let bodyBytes: [UInt8] = Array(body)
        if bodyBytes.count <= 4096 {
            let _ = try? socket.write(from: response.rawHeader + body)
        } else {
            response.setHeader(for: "Transfer-Encoding", to: "chunked")

            var c = bodyBytes.count
            var i = 0
            let _ = try? socket.write(from: response.rawHeader)

            let chunkSize = 2048

            while c >= chunkSize {
                let d: [UInt8] = Array(bodyBytes[(i*chunkSize)...(chunkSize*(i+1) - 1)])
                var d1: Data = (String(format: "%X", d.count) + "\r\n").data(using: .utf8)!
                d1.append(contentsOf: d)
                d1.append("\r\n".data(using: .utf8)!)

                let _ = try? socket.write(from: d1)
                c -= chunkSize
                i += 1
            }
            if c > 0 {
                let d: [UInt8] = Array(bodyBytes[(bodyBytes.count - c)...(bodyBytes.count - 1)])
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

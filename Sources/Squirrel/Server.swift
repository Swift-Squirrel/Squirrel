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
//    let bufferSize = 20
    var listenSocket: Socket? = nil
    var connected = [Int32: Socket]()
    var acceptNewConnection = true
    let serverRoot: Path
    /// url
    public let url: String
    /// global middlewares used for all routes
    public let middlewareGroup: [Middleware]
    /// Constructs erver
    ///
    /// - Parameters:
    ///   - base: Base url (default: "/")
    ///   - port: Port for HTTP requests (default: 8080)
    ///   - root: Root directory of server (default: "Public")
    ///   - globalMiddlewares: Middlewares used on all routes (default: [])
    public init(
        base: String = "/",
        port: UInt16 = Config.sharedInstance.port,
        serverRoot root: Path = Config.sharedInstance.serverRoot,
        globalMiddlewares: [Middleware] = []) {

        if base.first == "/" {
            self.url = base
        } else {
            squirrelConfig.log.warning(
                "Server base url should start with '/', (added automatically)")

            self.url = "/\(base)"
        }
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

        do {
            do {
                let request = try Request(socket: socket)
                log.info(request.method.rawValue + " " + request.path)
                log.verbose("\(request.remoteHostname) - \(request.method) \(request.path) \(request.headers)")
                let response = handle(request: request)
//                if request.acceptEncoding.count > 0 {
//                    if request.acceptEncoding.contains(.gzip) {
//                        response.contentEncoding = .gzip
//                    }
//                }
                if let range = request.range {
                    sendPartial(socket: socket, range: range, response: response)
                } else {
                    send(socket: socket, response: response)
                }
            } catch let error {
                let response = ErrorHandler.sharedInstance.response(for: error)
                log.error("unknown - \(response.status): \(error)")
                send(socket: socket, response: response)
                throw error
            }
        } catch let error {
            log.error("error with client: \(error.localizedDescription)")
        }
        connected.removeValue(forKey: socket.socketfd)
        socket.close()
    }

    private func handle(request: Request) -> Response {
        do {
            let handler = try getHandler(for: request)
            let handlerResult = try handler(request)
            return try Response.parseAnyResponse(any: handlerResult)
        } catch let error {
            let errorResponse = ErrorHandler.sharedInstance.response(for: error)
            log.error("\(request.remoteHostname) - \(errorResponse.status): \(error)")
            return errorResponse
        }
    }

    private func getHandler(for request: Request) throws -> AnyResponseHandler {
        if let handler = try ResponseManager.sharedInstance.findHandler(for: request) {
            return handler
        }
        let path: Path

        if (Config.sharedInstance.webRoot + "Storage").isSymlink
            && Path(request.path.lowercased()).httpNormalized.starts(with: ["storage"]) {

            var a = Path(request.path).string.split(separator: "/")
            a.removeFirst()
            path = (Config.sharedInstance.publicStorage + a.joined(separator: "/")).httpNormalized
        } else {
            let requestPath = String(request.path.dropFirst())
            path = (Config.sharedInstance.webRoot + requestPath).httpNormalized

            guard path.absolute().description.hasPrefix(Config.sharedInstance.webRoot.string) else {
                // TODO refactor and remove findHandler(for:)
                if let handler = try ResponseManager.sharedInstance.findHandler(for: request) {
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
                    return try Response(pathToFile: index)
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

    private func sendPartial(socket: Socket, range: (bottom: UInt, top: UInt), response: Response) {
        let bodyBytes = response.rawBody
        let top: UInt
        if range.top < response.bodyLength {
            top = range.top
        } else {
            top = UInt(response.bodyLength - 1)
        }
        let bottom: UInt
        if range.bottom <= top {
            bottom = range.bottom
        } else {
            bottom = top
        }
        let data = bodyBytes[bottom..<top + 1]
        response.headers[.connection] = "keep-alive"
        response.headers[.acceptRanges] = nil
        response.headers.set(to: .contentRange(
            start: bottom,
            end: top,
            from: UInt(bodyBytes.count)))

        let size = data.count
        response.headers.set(to: .contentLength(size: size))

        let head = response.rawPartialHeader
        let _ = try? socket.write(from: head + data)
    }

    private func send(socket: Socket, response: Response) {
        func sendChunked(head: Data, body: Data) {
            response.headers[.transferEncoding] = "chunked"
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

                let _ = try? socket.write(from: d1)
            }
            let _ = try? socket.write(from: "0\r\n\r\n".data(using: .utf8)!)
        }

        let body: Data
//        if response.contentEncoding == .gzip {
//            body = response.gzippedBody
//            response.headers.set(to: .contentEncoding(.gzip))
//        } else {
        body = response.rawBody
//        }
        response.headers.set(to: .contentLength(size: body.count))
        let head = response.rawHeader
        let _ = try? socket.write(from: head + body)
    }
}

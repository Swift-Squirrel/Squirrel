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
    private var listenSocket: Socket?
    /// Server run status
    public private(set) var runStatus: RunStatus = .stopped
    private var connected = [Int32: Socket]()
    private let semaphore = DispatchSemaphore(value: 1)
    private let dispatchGroup = DispatchGroup()

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

    /// Stops server, if finishConnections is set to true, server waits to
    /// finish all opened connections and stops accepting new connections.
    /// If false server will be immidiately stopped.
    ///
    /// - Parameter finishConnections: Let opened connections finish (default true)
    public func stop(finishConnections: Bool = true) {
        guard isRunning else {
            return
        }
        log.info("Server is stopping")
        semaphore.wait()
        runStatus = .stopping(now: !finishConnections)
        listenSocket?.close()
        listenSocket = nil
        semaphore.signal()
    }

    /// Pause server, call given closure and unpause server
    ///
    /// - Parameters:
    ///   - finishConnections: Waits to finish opened connections,
    ///     if finishConnections is set to true, server waits to finish
    ///     all opened connections and stops accepting new connections.
    ///     If false server will be immidiately stopped. (default true)
    ///   - closure: Closure to call when server is paused
    public func pause(finishConnections: Bool = true, closure: @escaping () -> Void) {
        guard isRunning else {
            return
        }
        log.info("Server is pausing")
        semaphore.wait()
        runStatus = .pausing(now: !finishConnections, closure: closure)
        listenSocket?.close()
        listenSocket = nil
        semaphore.signal()
    }

    /// Run server and start to listen on given `port` from `init(port:root:)`
    ///
    /// - Throws: Socket errors
    public func run() throws {
        // swiftlint:disable:prev function_body_length
        let queue = DispatchQueue(label: "clientQueue", attributes: .concurrent)
        repeat {
            let socket = try Socket.create()
            runStatus = .willRun
            listenSocket = socket
            defer {
                listenSocket?.close()
                listenSocket = nil
            }
            try socket.listen(on: Int(port),
                              maxBacklogSize: squirrelConfig.maximumPendingConnections,
                              allowPortReuse: false)
            log.info("Server is running on port \(socket.listeningPort)")
            runStatus = .running
            do {
                repeat {
                    let connectedSocket = try socket.acceptClientConnection()

                    dispatchGroup.enter()
                    log.verbose("Connection from: \(connectedSocket.remoteHostname)")
                    queue.async {
                        self.connected[socket.socketfd] = connectedSocket
                        self.newConnection(socket: connectedSocket)
                        self.connected.removeValue(forKey: connectedSocket.socketfd)
                        connectedSocket.close()
                        self.dispatchGroup.leave()
                    }
                } while isRunning
            } catch let error as Socket.Error {
                guard error.errorCode == Socket.SOCKET_ERR_ACCEPT_FAILED && !isRunning else {
                    throw error
                }
            }
            handleRunStatus()
        } while willRun
    }

    private func handleRunStatus() {
        semaphore.wait()
        switch runStatus {
        case .stopping(let now):
            if !now {
                log.debug("Server is waiting for opened connections")
                dispatchGroup.wait()
            }
            runStatus = .stopped
            log.info("Server is stopped")
        case .pausing(let now, let closure):
            if !now {
                log.debug("Server is waiting for opened connections")
                dispatchGroup.wait()
            }
            runStatus = .paused
            log.info("Server is paused")
            closure()
            log.debug("Server will run")
            runStatus = .willRun
        case .stopped, .paused, .willRun:
            assertionFailure("Unexpected server state")
        case .running:
            assertionFailure("Unexpected server state")
        }
        semaphore.signal()
    }

    func newConnection(socket: Socket) {
        do {
            do {
                let request = try Request(socket: socket)
                log.info(request.method.rawValue + " " + request.path)
                log.verbose("\(request.remoteHostname) - \(request.method) "
                    + "\(request.path) \(request.headers)")
                let response = handle(request: request)
//                if request.acceptEncoding.count > 0 {
//                    if request.acceptEncoding.contains(.gzip) {
//                        response.contentEncoding = .gzip
//                    }
//                }

                if let range = request.range, case .ok = response.status {
                    response.sendPartial(socket: socket, range: range)
                } else {
                    response.send(socket: socket)
                }
            } catch let error {
                if let sockErr = error as? Request.SocketError {
                    if sockErr.kind == .clientClosedConnection {
                        throw sockErr
                    }
                }
                let response = ErrorHandler.sharedInstance.response(for: error)
                log.error("unknown - \(response.status): \(error)")
                response.send(socket: socket)
                throw error
            }
        } catch let error {
            log.error("error with client: \(error)")
        }
    }

    private func handle(request: Request) -> ResponseProtocol {
        do {
            let handler = try getHandler(for: request)
            let handlerResult = try handler(request)
            return try parseAnyResponse(any: handlerResult)
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

        if (Config.sharedInstance.storage).isSymlink
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
}

// MARK: - Server + drop
public extension Server {
    /// Drops handler for given method and route
    ///
    /// - Parameters:
    ///   - method: Method type
    ///   - route: Route url
    public func drop(method: RequestLine.Method, on route: String) {
        ResponseManager.sharedInstance.drop(method: method, on: route)
    }
}

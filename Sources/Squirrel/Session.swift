//
//  Session.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/14/17.
//

import Foundation
import SquirrelJSON
import PathKit
import SquirrelConfig
import Crypto

/// Session protocol
public protocol SessionProtocol: class, Codable {
    /// Session ID
    var sessionID: String { get }
    /// Expiry of session
    var expiry: Date { get }

    /// Indicates if session is new (Do not modify)
    var isNew: Bool { set get }

    /// Ip address or hostname
    var remoteHostname: String { get }

    /// Indicates if session should be removed
    var shouldRemove: Bool { set get }

    /// Removes session
    ///
    /// - Returns: True on success
    func delete() -> Bool

    var data: [String: JSON] { set get }


    /// Get or set session parameter
    ///
    /// - Parameter key: Key
    subscript(key: String) -> JSON? { get set }
}

// MARK: - Subscript
public extension SessionProtocol {
    /// Number of stored elements
    var count: Int {
        return data.count
    }
}

class Session: SessionProtocol {

    var data: [String: JSON] = [:]

    var sessionID: String

    let expiry: Date

    let userAgent: String

    let remoteHostname: String

    var isNew: Bool = false

    var shouldRemove: Bool = false

    init(id: String, expiry: Date, remoteHostname: String, userAgent: String) {
        self.remoteHostname = remoteHostname
        self.sessionID = id
        self.expiry = expiry
        self.userAgent = userAgent
        let _ = store()
    }

    init?(id: String, remoteHostname: String, userAgent: String) {
        let file = SessionConfig.storage + "\(id).session"
        guard let data: Data = try? file.read() else {
            return nil
        }
        let decoder = JSONDecoder()
        guard let json = try? decoder.decode(Session.self, from: data) else {
            return nil
        }
        guard json.remoteHostname == remoteHostname && json.userAgent == userAgent else {
            return nil
        }
        guard json.expiry > Date() else {
            try? file.delete() // TODO rethink it
            return nil
        }

        self.remoteHostname = json.remoteHostname
        self.data = json.data
        self.expiry = json.expiry
        self.sessionID = json.sessionID
        self.userAgent = json.userAgent
    }

    func store() -> Bool {
        let file: Path = SessionConfig.storage + "\(sessionID).session"
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(self) else {
            return false
        }
        return (try? file.write(data)) != nil
    }

    /// Remove session
    ///
    /// - Returns: true if everything goes ok
    func delete() -> Bool {
        shouldRemove = true
        let file: Path = SessionConfig.storage + "\(sessionID).session"
        return (try? file.delete()) != nil
    }

    subscript(key: String) -> JSON? {
        get {
            return data[key]
        }
        set(value) {
            data[key] = value
            let _ = store()
        }
    }
}

/// Session builder
public protocol SessionBuilder {
    /// Creates new session
    ///
    /// - Parameter request: Request
    /// - Returns: New session or nil if session could not be created
    func new(for request: Request) -> SessionProtocol?

    /// Get new session
    ///
    /// - Parameter request: Request
    /// - Returns: Existing session or nil if could not get session
    func get(for request: Request) -> SessionProtocol?
}

/// Session configurations
public struct SessionConfig {
    private init() { }

    /// Session name
    public static var sessionName = "SquirrelSession"

    /// Session duration
    public static var defaultExpiry = 60.0 * 60.0 * 24.0 * 7.0

    static let userAgent = "user-agent"

    static let storage = squirrelConfig.session
}

struct SessionManager: SessionBuilder {

    func new(for request: Request) -> SessionProtocol? {
        guard let userAgent = request.headers[SessionConfig.userAgent] else {
            return nil
        }

        guard let host = request.remoteHostname.data(using: .utf8) else {
            return nil
        }

        guard let date = Date().description.data(using: .utf8) else {
            return nil
        }

        guard let random = try? Random().bytes(count: 32) else {
            return nil
        }

        let sessionIDData = host + date + random
        guard let hash = try? Hash(.md5, sessionIDData) else {
            return nil
        }

        guard let hashValue = try? hash.hash() else {
            return nil
        }

        let id = hashValue.hexString

        return Session(
            id: id,
            expiry: Date().addingTimeInterval(SessionConfig.defaultExpiry),
            remoteHostname: request.remoteHostname,
            userAgent: userAgent)
    }

    func get(for request: Request) -> SessionProtocol? {
        guard let userAgent = request.headers[SessionConfig.userAgent] else {
            return nil
        }
        guard let id = request.getCookie(for: SessionConfig.sessionName) else {
            return nil
        }
        return Session(id: id, remoteHostname: request.remoteHostname, userAgent: userAgent)
    }
}

/// Session middleware
public struct SessionMiddleware: Middleware {

    private let sessionManager: SessionBuilder

    /// Handle session for given request. If there is no session cookie,
    /// creates new session and put session cookie to response.
    ///
    /// - Parameters:
    ///   - request: Request
    ///   - next: Next middleware or Response handler
    /// - Returns: badRequest or Response from `next`
    /// - Throws: Custom error or parsing error
    public func respond(to request: Request, next: AnyResponseHandler) throws -> Any {
        if let session: SessionProtocol = sessionManager.get(for: request) {
            request.setSession(session)
        }
        let res = try next(request)
        guard request.sessionExists else {
            return res
        }
        let session = try request.session()
        guard session.isNew || session.shouldRemove else {
            return res
        }
        let response = try parseAnyResponse(any: res)
        let domain = squirrelConfig.domain
        if session.isNew {
            response.cookies[SessionConfig.sessionName] = """
                \(session.sessionID); domain=\(domain);path=/; HTTPOnly
                """
        } else if session.shouldRemove {
            let _ = session.delete()
            response.cookies[SessionConfig.sessionName] = """
                removed; domain=\(domain);path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; HTTPOnly
                """
        }
        return response

    }

    /// Constructs Session middleware
    ///
    /// - Parameter dataInit: This will init session data when new session is established
    public init(sessionBuilder: SessionBuilder? = nil) {
        if let sessionBuilder = sessionBuilder {
            self.sessionManager = sessionBuilder
        } else {
            self.sessionManager = SessionManager()
        }
    }
}

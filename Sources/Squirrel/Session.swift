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
public protocol Session: class, Codable {
    /// Session ID
    var sessionID: String { get }
    /// Expiry of session
    var expiry: Date { get }

    /// Indicates if session is new (Do not modify!)
    var _isNew: Bool { get set }

    /// Ip address or hostname
    var remoteHostname: String { get }

    /// Indicates if session should be removed
    var shouldRemove: Bool { get set }

    /// Removes session
    ///
    /// - Returns: True on success
    func delete() -> Bool

    var data: [String: JSON] { get }

    /// Get or set session parameter
    ///
    /// - Parameter key: Key
    subscript(key: String) -> JSON? { get set }
}

// MARK: - Subscript
public extension Session {
    /// Number of stored elements
    var count: Int {
        return data.count
    }
}

class DefaultSession: Session {

    private(set) var data: [String: JSON] = [:]

    let sessionID: String

    let expiry: Date

    let userAgent: String

    let remoteHostname: String

    var _isNew: Bool = false

    var shouldRemove: Bool = false

    init(id: String, expiry: Date, remoteHostname: String, userAgent: String) {
        self.remoteHostname = remoteHostname
        self.sessionID = id
        self.expiry = expiry
        self.userAgent = userAgent
        _ = store()
    }

    init?(id: String, remoteHostname: String, userAgent: String) {
        let file = SessionConfig.storage + "\(id).session"
        guard let data: Data = try? file.read() else {
            return nil
        }
        let decoder = JSONDecoder()
        guard let json = try? decoder.decode(DefaultSession.self, from: data) else {
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
            _ = store()
        }
    }

    static func needsRemove(file: Path) -> Bool {
        guard let data: Data = try? file.read() else {
            return false
        }
        let decoder = JSONDecoder()
        struct Expiration: Decodable {
            let expiry: Date
        }
        guard let json = try? decoder.decode(Expiration.self, from: data) else {
            return true
        }
        guard json.expiry > Date() else {
            return true
        }
        return false
    }
}

/// Session builder
public protocol SessionBuilder {
    /// Creates new session
    ///
    /// - Parameter request: Request
    /// - Returns: New session or nil if session could not be created
    func new(for request: Request) -> Session?

    /// Get new session
    ///
    /// - Parameter request: Request
    /// - Returns: Existing session or nil if could not get session
    func get(for request: Request) -> Session?

    /// Clears expired sessions
    func clearExpired()
}

/// Session configurations
public struct SessionConfig {
    private init() { }

    /// Session name
    public static var sessionName = "SquirrelSession"

    /// Session duration (default: one week)
    public static var defaultExpiry = 604_800.0

    static let storage = squirrelConfig.session
}

struct SessionManager: SessionBuilder {

    func new(for request: Request) -> Session? {
        guard let userAgent = request.headers[.userAgent] else {
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

        return DefaultSession(
            id: id,
            expiry: Date().addingTimeInterval(SessionConfig.defaultExpiry),
            remoteHostname: request.remoteHostname,
            userAgent: userAgent)
    }

    func get(for request: Request) -> Session? {
        guard let userAgent = request.headers[.userAgent] else {
            return nil
        }
        guard let id = request.cookie(for: SessionConfig.sessionName) else {
            return nil
        }
        return DefaultSession(id: id, remoteHostname: request.remoteHostname, userAgent: userAgent)
    }

    func clearExpired() {
        let sessionsDirectory = squirrelConfig.session
        guard let children = try? sessionsDirectory.children() else {
            return
        }
        for child in children where child.isFile {
            if DefaultSession.needsRemove(file: child) {
                try? child.delete()
            }
        }
    }
}

/// Session middleware
public class SessionMiddleware: Middleware {

    private let sessionManager: SessionBuilder
    private var schedulerQueue = DispatchQueue(label: "clean session")

    /// Day in seconds
    public static let dayInSeconds = 86_400

    /// Time between two session clears
    /// - Note:
    ///   You can't set `.days` or `.seconds` to 0.
    ///   This will set to `.never` instead and produce warning
    public var clearAfter: TimeSheduling {
        didSet {
            switch clearAfter {
            case .days(let time) where time == 0, .seconds(let time) where time == 0:
                log.warning("You should not set clearAfter in SessionMiddleware to 0, using .never")
                clearAfter = .never
            default:
                break
            }
        }
    }

    /// Time interval
    ///
    /// - never: Never
    /// - days: Number of days
    /// - seconds: Number of seconds
    public enum TimeSheduling {
        case never
        case days(UInt)
        case seconds(UInt)
    }

    /// Handle session for given request. If there is no session cookie,
    /// creates new session and put session cookie to response.
    ///
    /// - Parameters:
    ///   - request: Request
    ///   - next: Next middleware or Response handler
    /// - Returns: badRequest or Response from `next`
    /// - Throws: Custom error or parsing error
    public func respond(to request: Request, next: AnyResponseHandler) throws -> Any {
        if let session: Session = sessionManager.get(for: request) {
            request.setSession(session)
        }
        let res = try next(request)
        guard request.sessionExists else {
            return res
        }
        let session = try request.session()
        guard session._isNew || session.shouldRemove else {
            return res
        }
        let response = try parseAnyResponse(any: res)
        let domain = squirrelConfig.domain
        if session._isNew {
            response.setCookie(SessionConfig.sessionName, to: """
                \(session.sessionID); domain=\(domain);path=/; HTTPOnly
                """)
        } else if session.shouldRemove {
            _ = session.delete()
            response.setCookie(SessionConfig.sessionName, to: """
                removed; domain=\(domain);path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; HTTPOnly
                """)
        }
        return response
    }

    /// Inits session middleware
    ///
    /// - Parameters:
    ///   - sessionBuilder: Session builder used to handle sessions
    ///   - clearAfterEvery: Time to clear expired sessions
    public init(sessionBuilder: SessionBuilder? = nil, clearAfterEvery: TimeSheduling = .days(1)) {
        if let sessionBuilder = sessionBuilder {
            self.sessionManager = sessionBuilder
        } else {
            self.sessionManager = SessionManager()
        }
        self.clearAfter = clearAfterEvery
        switch self.clearAfter {
        case .never:
            break
        default:
            clearExpiredSessions()
            scheduleClear()
        }
    }

    private func scheduleClear() {
        let after: Int
        switch clearAfter {
        case .never:
            return
        case .days(let days):
            after = Int(days) * SessionMiddleware.dayInSeconds
        case .seconds(let seconds):
            after = Int(seconds)
        }
        schedulerQueue.asyncAfter(deadline: DispatchTime(secondsFromNow: Double(after)),
                                  qos: .background) { [weak self] in
            guard let s = self else {
                return
            }
            switch s.clearAfter {
            case .never:
                return
            default:
                break
            }
            s.clearExpiredSessions()
            s.scheduleClear()
        }
    }

    /// Clears expired sessions
    public func clearExpiredSessions() {
        log.debug("Clearing expired sessions")
        sessionManager.clearExpired()
    }
}

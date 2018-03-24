//
//  Config.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation
import PathKit
import SwiftyBeaver
import Yams

/// Squirrel config shared instance
public let squirrelConfig = Config.sharedInstance

/// Squirrel config class
public class Config {
    private var _serverRoot: Path = Path().absolute()
    private let _webRoot: Path
    private let _cache: Path
    private var _port: UInt16 = 8000
    private let _isAllowedDirBrowsing: Bool
    private let _logDir: Path
    private let _logFile: Path
    private let _resourcesDir: Path
    private let _viewsDir: Path
    private let _storageViews: Path
    private let _configFile: Path?
    private let _publicStorage: Path

    /// Maximum pending connections
    public let maximumPendingConnections: Int

    /// Sotrage directory
    public let storage: Path

    /// Symlink to public storage
    private let publicStorageSymlink: Path

    /// Session directory
    public let session: Path

    /// Domain name or IP
    public let domain: String

    /// Logger
    public let log = SwiftyBeaver.self

    private let logFileName = "server.log"

    /// Log file destination
    public var logFile: Path {
        return _logFile
    }

    /// Server root destination
    public var serverRoot: Path {
        return _serverRoot
    }
    /// Webroot destination
    public var webRoot: Path {
        return _webRoot
    }
    /// Cache destination
    public var cache: Path {
        return _cache
    }
    /// HTTP Requests port
    public var port: UInt16 {
        return _port
    }
    /// If is allowed directory browsing
    public var isAllowedDirBrowsing: Bool {
        return _isAllowedDirBrowsing
    }

    /// Storage views destination
    public var storageViews: Path {
        return _storageViews
    }

    /// Views *.nut* destination
    public var views: Path {
        return _viewsDir
    }

    /// Public storage destination
    public var publicStorage: Path {
        return _publicStorage
    }

    /// Shared instance
    public static let sharedInstance = Config()

    private static func getEnviromentVariable(name: String) -> String? {
        let start = name.index(after: name.startIndex)
        let key = String(name[start..<name.endIndex])
        return ProcessInfo.processInfo.environment[key]
    }

    private static func getStringVariable(from node: Node?) -> String? {
        guard let string = node?.string else {
            return nil
        }
        if string.first == "$" {
            return getEnviromentVariable(name: string)
        }
        return string
    }

    private static func getIntVariable(from node: Node?) -> Int? {
        guard let node = node else {
            return nil
        }

        if let string = node.string, string.first == "$" {
            guard let value = getEnviromentVariable(name: string) else {
                return nil
            }
            return Int(value)
        }
        return node.int
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    private init() {
        let configFile: Path = {
            let p1 = Path().absolute() + ".squirrel.yaml"
            if p1.exists {
                return p1
            }
            return Path().absolute() + ".squirrel.yml"
        }()
        var domainConfig = "127.0.0.1"
        var maxPendingConnectionsConfig = 50
        if configFile.exists {
            _configFile = configFile
            do {
                let content: String = try configFile.read()
                guard let yaml = try compose(yaml: content) else {
                    throw ConfigError(kind: .yamlSyntax)
                }

                if let serv = yaml["server"] {
                    if let serverRoot = Config.getStringVariable(from: serv["serverRoot"]) {
                        let sr = Path(serverRoot).absolute()
                        if sr.exists {
                            _serverRoot = sr
                        } else {
                            print(sr.string + " does not exists using default server root")
                        }
                    }
                    if let port = Config.getIntVariable(from: serv["port"]) {
                        _port = UInt16(port)
                    }
                    if let dom = Config.getStringVariable(from: serv["domain"]) {
                        domainConfig = dom
                    }
                    if let maxPending = Config.getIntVariable(from: serv["max_pending"]) {
                        maxPendingConnectionsConfig = maxPending
                    }
                }
            } catch {
                print("config.yaml is not valid, using default values")
            }
        } else {
            _configFile = nil
        }
        maximumPendingConnections = maxPendingConnectionsConfig
        domain = domainConfig
        _webRoot = _serverRoot + "Public"
        publicStorageSymlink = _webRoot + "Storage"
        storage = _serverRoot + "Storage"
        _cache = storage + "Cache"
        _publicStorage = storage + "Public"
        _logDir = storage + "Logs"
        session = storage + "Sessions"
        _logFile = _logDir + logFileName
        _resourcesDir = _serverRoot + "Resources"
        _viewsDir = _resourcesDir + "NutViews"
        _storageViews = storage + "Fruits"

        _isAllowedDirBrowsing = false

        initLog()
        createDirectories()

        if !(publicStorageSymlink.exists && publicStorageSymlink.isSymlink) {
            // TODO remove force try
            // swiftlint:disable:next force_try
            try! publicStorageSymlink.symlink(publicStorage)
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

    /// Get database config from config file
    ///
    /// - Returns: dabase config data
    /// - Throws: Yaml error, File read error
    public func getDBData() throws -> DBCredentials {
        guard let configFile = _configFile else {
            throw ConfigError(kind: .missingConfigFile)
        }
        let content: String = try configFile.read()
        guard let yaml = try Yams.load(yaml: content) as? [String: Any] else {
            throw ConfigError(kind: .yamlSyntax)
        }
        guard let dbDataYaml = yaml["MongoDB"] as? [String: Any] else {
            throw ConfigError(kind: .missingDBConfig)
        }
        guard let host = dbDataYaml["host"] as? String else {
            throw ConfigError(kind: .missingValue(for: "host"))
        }
        let dbname = (dbDataYaml["dbname"] as? String) ?? "squirrel"
        let port = (dbDataYaml["port"] as? Int) ?? 27017
        let user: DBCredentials.UserCredentails?
        if let username = dbDataYaml["username"] as? String,
            let password = dbDataYaml["password"] as? String {
            user = DBCredentials.UserCredentails(username: username, password: password)
        } else {
            user = nil
        }
        return DBCredentials(user: user, dbname: dbname, host: host, port: port)
    }

    private func initLog() {
        let console = ConsoleDestination()
        console.minLevel = .verbose

        #if !Xcode
            console.useTerminalColors = true
        #endif

        let file = FileDestination()
        file.logFileURL = URL(fileURLWithPath: logFile.description)

        log.addDestination(console)
        log.addDestination(file)
    }

    private func createDir(path dir: Path) {
        guard !dir.exists else {
            return
        }
        try? dir.mkpath()
        log.info("creating folder: \(dir.string)")
    }

    private func createDirectories() {
        createDir(path: _logDir)
        createDir(path: serverRoot)
        createDir(path: webRoot)
        createDir(path: storageViews)
        createDir(path: views)
        createDir(path: cache)
        createDir(path: publicStorage)
        createDir(path: session)
    }
}

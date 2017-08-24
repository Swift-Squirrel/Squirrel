//
//  Config.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation
import SquirrelConnector
import PathKit
import SwiftyBeaver
import Yaml

public let squirrelConfig = Config.sharedInstance

public class Config {
    private var _serverRoot: Path = Path().absolute()
    private let _webRoot: Path
    private let _cache: Path
    private var _port: UInt16 = 8080
    private let _isAllowedDirBrowsing: Bool
    private let _logDir: Path
    private let _logFile: Path
    private let _resourcesDir: Path
    private let _viewsDir: Path
    private let _storage: Path
    private let _storageViews: Path
    private let _configFile: Path?
    private let _assets: Path

    public let log = SwiftyBeaver.self

    private let logFileName = "server.log"

    public var logFile: Path {
        return _logFile
    }

    public var serverRoot: Path {
        return _serverRoot
    }
    public var webRoot: Path {
        return _webRoot
    }
    public var cache: Path {
        return _cache
    }
    public var port: UInt16 {
        return _port
    }
    public var isAllowedDirBrowsing: Bool {
        return _isAllowedDirBrowsing
    }

    public var storageViews: Path {
        return _storageViews
    }

    public var assets: Path {
        return _assets
    }

    public var views: Path {
        return _viewsDir
    }

    public static let sharedInstance = Config()

    private init() {
        let configFile = Path().absolute() + ".squirrel.yaml"
        if configFile.exists {
            _configFile = configFile
            do {
                let content: String = try configFile.read()
                let yaml = try Yaml.load(content)
                let serv = yaml["server"]
                if let serverRoot = serv["serverRoot"].string {
                    let sr = Path(serverRoot).absolute()
                    if sr.exists {
                        _serverRoot = sr
                    } else {
                        print(sr.string + " does not exists using default server root")
                    }
                }
                if let port = serv["port"].int {
                    _port = UInt16(port)
                }

            } catch {
                print("config.yaml is not valid, using default values")
            }
        } else {
            _configFile = nil
        }

        _webRoot = _serverRoot + "Public"
        _cache = _serverRoot + "Storage/Cache"
        _storage = _serverRoot + "Storage"
        _logDir = _storage + "Logs"
        _logFile = _logDir + logFileName
        _resourcesDir = _serverRoot + "Resources"
        _assets = _serverRoot + "Assets"
        _viewsDir = _resourcesDir + "Views"
        _storageViews = _storage + "Views"

        _isAllowedDirBrowsing = false

        initLog()
        createDirectories()
    }


    /// Set database connector and initialize it
    ///
    /// - Throws: Error if *squirrel.yaml* does not contains all important values
    public func setConnector() throws {
        let dbData: DBCredentials
        do {
            dbData = try getDBData()
        } catch let error as ConfigError {
            switch error.kind {
            case .missingConfigFile:
                log.warning("Configuration file is missing")
                return
            case .missingDBConfig:
                log.warning("Database is not set because configuration is missing")
                return
            default:
                throw error
            }
        }
        let res: Bool
        if let user = dbData.user {
            res = Connector.setConnector(username: user.username, password: user.password,
                                   host: dbData.host, port: dbData.port, dbname: dbData.dbname)
        } else {
            res = Connector.setConnector(host: dbData.host, port: dbData.port, dbname: dbData.dbname)
        }
        if res {
            log.info("Connected to database with: '\(dbData)'")
        } else {
            throw ConfigError(kind: .canNotConnect(using: dbData))
        }
    }

    private func getDBData() throws -> DBCredentials {
        guard let configFile = _configFile else {
            throw ConfigError(kind: .missingConfigFile)
        }
        let content: String = try configFile.read()
        let yaml = try Yaml.load(content)
        guard let dbDataYaml = yaml["MongoDB"].dictionary else {
            throw ConfigError(kind: .missingDBConfig)
        }
        guard let host = dbDataYaml["host"]?.string else {
            throw ConfigError(kind: .missingValue(for: "host"))
        }
        let dbname = dbDataYaml["dbname"]?.string ?? "squirrel"
        let port = dbDataYaml["port"]?.int ?? 27017
        let user: DBCredentials.UserCredentails?
        if let username = dbDataYaml["username"]?.string, let password = dbDataYaml["password"]?.string {
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
    
    private func createDir(url: String) {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url) {
            try? fileManager.createDirectory(atPath: url, withIntermediateDirectories: true) // TODO handle
            log.info("creating folder: \(url)")
        }
    }

    private func createDirectories() {
        createDir(path: _logDir)
        createDir(path: serverRoot)
        createDir(path: webRoot)
        createDir(path: storageViews)
        createDir(path: cache)
        createDir(path: assets)
    }
}

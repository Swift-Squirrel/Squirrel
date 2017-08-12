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

// TODO use PathKit

public class Config {
    private let _serverRoot: String
    private let _webRoot: String
    private let _cache: String
    private let _port: UInt16
    private let _isAllowedDirBrowsing: Bool
    private let _logDir: Path
    private let _logFile: Path
    private let _resourcesDir: Path
    private let _viewsDir: Path
    private let _storage: Path
    private let _storageViews: Path

    public let log = SwiftyBeaver.self

    private let logFileName = "server.log"

    public var logFile: Path {
        return _logFile
    }

    public var serverRoot: String {
        return _serverRoot
    }
    public var webRoot: String {
        return _webRoot
    }
    public var cache: String {
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

    public var views: Path {
        return _viewsDir
    }

    public static let sharedInstance = Config()

    private init() {
        _serverRoot = "/Users/Navel/Leo/Skola/3BIT/IBT/Squirrel"
        _webRoot = _serverRoot + "/Public"
        _cache = _serverRoot + "/Storage/Cache"
        _storage = Path(components: [_serverRoot, "Storage"])
        _logDir = Path(components: [_storage.string, "Logs"])
        _logFile = Path(components: [_logDir.description, logFileName])
        _resourcesDir = Path(components: [_serverRoot, "Resources"]).absolute()
        _viewsDir = Path(components: [_resourcesDir.string, "Views"])
        _storageViews = Path(components: [_storage.string, "Views"])

        _port = 8080
        _isAllowedDirBrowsing = false

        initLog()
        createDirectories()
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
        createDir(url: _logDir.description)
        createDir(url: serverRoot)
        createDir(url: webRoot)
        createDir(path: storageViews)
        createDir(url: cache)
    }
}

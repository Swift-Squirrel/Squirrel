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

class Config {
    private let _serverRoot: String
    private let _webRoot: String
    private let _cache: String
    private let _port: UInt16
    private let _isAllowedDirBrowsing: Bool
    private let _logDir: Path
    private let _logFile: Path

    private let logFileName = "server.log"

    var logFile: Path {
        return _logFile
    }

    var serverRoot: String {
        return _serverRoot
    }
    var webRoot: String {
        return _webRoot
    }
    var cache: String {
        return _cache
    }
    var port: UInt16 {
        return _port
    }
    var  isAllowedDirBrowsing: Bool {
        return _isAllowedDirBrowsing
    }

    static let sharedInstance = Config()

    private init() {
        _serverRoot = "/Users/Navel/Leo/Skola/3BIT/IBT/Micros"
        _webRoot = _serverRoot + "/Public"
        _cache = _serverRoot + "/Storage/Cache"
        _logDir = Path(components: [_serverRoot, "Storage/Logs"])
        _logFile = Path(components: [_logDir.description, logFileName])
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
        createDir(url: cache)
    }
}

//
//  Config.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation

class Config {
    private let _serverRoot: String
    private let _webRoot: String
    private let _cache: String
    private let _port: UInt16
    
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
    
    private static var _sibling: Config? = nil
    
    static var sibling: Config {
        if _sibling == nil {
            _sibling = Config()
        }
        return _sibling!
    }
    
    private init() {
        _serverRoot = "/Users/Millie/Developer/Micros"
        _webRoot = _serverRoot + "/Public"
        _cache = _serverRoot + "/Storage/Cache"
        _port = 8080
        
        createDirectories()
    }
    
    private func createDir(url: String) {
        let fileManager = FileManager.default
        if(!fileManager.fileExists(atPath: url)) {
            try? fileManager.createDirectory(atPath: url, withIntermediateDirectories: true)
        }
    }
    
    private func createDirectories() {
        createDir(url: serverRoot)
        createDir(url: webRoot)
        createDir(url: cache)
    }
}
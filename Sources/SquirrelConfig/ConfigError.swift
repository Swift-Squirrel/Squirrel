//
//  ConfigError.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/14/17.
//
//

struct ConfigError: Error, CustomStringConvertible {
    enum ErrorKind {
        case missingConfigFile
        case missingDBConfig
        case missingValue(for: String)
        case canNotConnect(using: DBCredentials)
        case yamlSyntax
    }

    let kind: ErrorKind

    var description: String {
        switch kind {
        case .missingConfigFile:
            return "Configuration file 'squirrel.yaml' is missing"
        case .missingDBConfig:
            return "Configuration file does not contains database configuration"
        case .missingValue(let `for`):
            return "Missing or invalid value for '\(`for`)'"
        case .canNotConnect(let cred):
            return "Can not connect to database using: '\(cred)'"
        case .yamlSyntax:
            return "Error when parsing yaml"
        }
    }

    init(kind: ErrorKind) {
        self.kind = kind
    }
}

//
//  NutError.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/12/17.
//
//

public struct NutParserError: Error, CustomStringConvertible {
    public enum ErrorKind {
        case unknownInternalError(commandName: String)
    }
    public let kind: ErrorKind
    public let row: UInt
//    public let column: UInt
    private let _description: String?
    public var description: String {
        var res = ""
        switch kind {
        case .unknownInternalError(let name):
            res = "Internal error on command: \(name)"
        }
        res += "\nRow:\(row)"
        if let desc = _description {
            res += "\nDescription: \(desc)"
        }
        return res
    }

    init(kind: ErrorKind, row: UInt, description: String? = nil) {
        self.kind = kind
        self._description = description
        self.row = row
    }
}

public struct NutError: Error, CustomStringConvertible {
    public enum ErrorKind {
        case notExists(name: String)
        case missingValue(for: String)
        case wrongValue(for: String, expected: String, got: Any)
    }

    public let kind: ErrorKind
    private let _description: String?
    public var description: String {
        var res = ""
        switch kind {
        case .notExists(let name):
            res = "Nut file: \(name) does not exists"
        case .missingValue(let name):
            res = "Missing value for \(name)"
        case .wrongValue(let name, let expected, let got):
            res = "Wrong value for \(name), expected: '\(expected)' but got '\(String(describing: got))'"
        }

        if let desc = _description {
            res += "\nDescription: \(desc)"
        }
        return res
    }

    init(kind: ErrorKind, description: String? = nil) {
        self.kind = kind
        self._description = description
    }
}

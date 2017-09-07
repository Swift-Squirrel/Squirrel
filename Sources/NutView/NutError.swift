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
        case unexpectedEnd(reading: String)
        case unexpectedBlockEnd
        case syntaxError(expected: [String], got: String)
        case expressionError
        case missingValue(for: String)
        case evaluationError(infix: String, message: String)
        case wrongValue(for: String, expected: String, got: Any)
        case wrongSimpleVariable(name: String, in: String)
        case wrongChainedVariable(name: String, in: String)
    }
    public let kind: ErrorKind
    public var name: String? = nil
    public let row: Int
    private let _description: String?
    public var description: String {
        var res = ""
        switch kind {
        case .unknownInternalError(let name):
            res = "Internal error on command: \(name)"
        case .unexpectedEnd(let reading):
            res = "Unexpected end of file while reading: \(reading)"
        case .syntaxError(let expected, let got):
            res = "Syntax error\nexpected: \n\t" + expected.flatMap( { "'" + $0 + "'" } ).joined(separator: "\n\t") + "\nbut got: \n\t'\(got)'"
        case .expressionError:
            res = "Expression error"
        case .evaluationError(let infix, let message):
            res = "Evaluation error in '\(infix)', message: '\(message)'"
        case .missingValue(let name):
            res = "Missing value for \(name)"
        case .wrongValue(let name, let expected, let got):
            res = "Wrong value for \(name), expected: '\(expected)' but got '\(String(describing: got))'"
        case .wrongSimpleVariable(let name, let command):
            res = "Variable name '\(name)' in '\(command)' does not match regular expression '[a-zA-Z][a-zA-Z0-9]*'"
        case .wrongChainedVariable(let name, let command):
            res = "Variable name '\(name)' in '\(command)' does not match regular expression '[a-zA-Z][a-zA-Z0-9]*(\\.[a-zA-Z][a-zA-Z0-9]*)*'"
        case .unexpectedBlockEnd:
            res = "Unexpected '\\}'"
        }
        if let name = self.name {
            res += "\nFile name: \(name)"
        }
        res += "\nRow:\(row)"
        if let desc = _description {
            res += "\nDescription: \(desc)"
        }
        return res
    }

    init(kind: ErrorKind, row: Int, description: String? = nil) {
        self.kind = kind
        self._description = description
        self.row = row
    }
}

public struct NutError: Error, CustomStringConvertible {
    public enum ErrorKind {
        case notExists(name: String)
    }

    public let kind: ErrorKind
    private let _description: String?
    public var description: String {
        var res = ""
        switch kind {
        case .notExists(let name):
            res = "Nut file: \(name) does not exists"
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

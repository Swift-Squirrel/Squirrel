//
//  NutError.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/12/17.
//
//

/// Nut parser errors
public struct NutParserError: Error, CustomStringConvertible {
    /// Error kinds
    ///
    /// - unknownInternalError: Something unexpected happened
    /// - unexpectedEnd: Parser expect specific token but EOF found
    /// - unexpectedBlockEnd: Parser does not expect '\}'
    /// - syntaxError: Syntax error
    /// - expressionError: Error while evaluating expression
    /// - missingValue: Missing value for variable
    /// - evaluationError: Error while evaluating expression
    /// - wrongValue: Parser expect different type of fiven value
    /// - wrongSimpleVariable: Parser expect common variable name `[a-zA-Z][a-zA-Z0-9]*`
    /// - wrongChainedVariable: Parser expect dot convention variable name
    ///    `[a-zA-Z][a-zA-Z0-9]*(\.[a-zA-Z][a-zA-Z0-9]*)*`
    public enum ErrorKind {
        case unknownInternalError(commandName: String)
        case unexpectedEnd(reading: String)
        case unexpectedBlockEnd
        case syntaxError(expected: [String], got: String)
        case expressionError
        case missingValue(for: String)
        case evaluationError(infix: String, message: String)
        case wrongValue(for: String, expected: String, got: Any)
        case wrongSimpleVariable(name: String, in: String, regex: String)
        case wrongChainedVariable(name: String, in: String, regex: String)
    }
    /// Kind of error
    public let kind: ErrorKind
    /// Name of file
    public var name: String? = nil
    /// line of error
    public let line: Int
    private let _description: String?
    /// Description
    public var description: String {
        var res = ""
        switch kind {
        case .unknownInternalError(let name):
            res = "Internal error on command: \(name)"
        case .unexpectedEnd(let reading):
            res = "Unexpected end of file while reading: \(reading)"
        case .syntaxError(let expected, let got):
            res = """
                Syntax error
                expected:
                    \(expected.flatMap({ "'" + $0 + "'" }).joined(separator: "\n\t"))
                but got:
                    '\(got)'
                """
        case .expressionError:
            res = "Expression error"
        case .evaluationError(let infix, let message):
            res = "Evaluation error in '\(infix)', message: '\(message)'"
        case .missingValue(let name):
            res = "Missing value for \(name)"
        case .wrongValue(let name, let expected, let got):
            res = "Wrong value for \(name), expected: '\(expected)' "
                + "but got '\(String(describing: got))'"
        case .wrongSimpleVariable(let name, let command, let regex):
            res = "Variable name '\(name)' in '\(command)' does not match "
                + "regular expression '\(regex)'"
        case .wrongChainedVariable(let name, let command, let regex):
            res = "Variable name '\(name)' in '\(command)' does not match "
                + "regular expression '\(regex)'"
        case .unexpectedBlockEnd:
            res = "Unexpected '\\}'"
        }
        if let name = self.name {
            res += "\nFile name: \(name)"
        }
        res += "\nLine:\(line)"
        if let desc = _description {
            res += "\nDescription: \(desc)"
        }
        return res
    }

    init(kind: ErrorKind, line: Int, description: String? = nil) {
        self.kind = kind
        self._description = description
        self.line = line
    }
}

/// Error struct for common errors in NutView
public struct NutError: Error, CustomStringConvertible {
    /// Error kinds
    ///
    /// - notExists: File does not exists
    public enum ErrorKind {
        case notExists(name: String)
    }

    /// Kind of error
    public let kind: ErrorKind
    private let _description: String?
    /// Description
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

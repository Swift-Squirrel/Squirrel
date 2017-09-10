//
//  JSONError.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/5/17.
//
//

/// JSON Error
public struct JSONError: Error {
    /// Error kinds
    ///
    /// - parseError: Parser error
    /// - encodeError: Can not encode
    /// - dataEncodingError: Data Encoding error
    public enum ErrorKind {
        case parseError
        case encodeError
        case dataEncodingError
    }

    /// Error kind
    public let kind: ErrorKind
    /// Description
    public let message: String

    /// Construct error
    ///
    /// - Parameters:
    ///   - kind: Error kind
    ///   - message: Description
    public init(kind: ErrorKind, message: String) {
        self.kind = kind
        self.message = message
    }
}

//
//  JSONError.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/5/17.
//
//

public struct JSONError: Error {
    public enum ErrorKind {
        case parseError
        case encodeError
        case dataEncodingError
    }

    public let kind: ErrorKind
    public let message: String

    public init(kind: ErrorKind, message: String) {
        self.kind = kind
        self.message = message
    }
}

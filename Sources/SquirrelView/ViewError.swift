//
//  ViewError.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

public struct ViewError: Error, CustomStringConvertible {
    public enum ErrorKind {
        case notExists
        case getModif
    }

    public init(kind: ErrorKind, description: String) {
        self.kind = kind
        self.description = description
    }

    public let kind: ErrorKind

    public var description: String
}


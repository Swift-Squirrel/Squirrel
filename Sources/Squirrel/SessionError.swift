//
//  SessionError.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/17/17.
//

import SquirrelCore

struct SessionError: SquirrelError, HTTPConvertibleError {
    var asHTTPError: HTTPError {
        switch kind {
        case .missingSession:
            return HTTPError(.internalError, description: self.description)
        case .cantEstablish:
            return HTTPError(.badRequest, description: self.description)
        }
    }

    enum ErrorKind {
        case missingSession
        case cantEstablish
    }

    let kind: ErrorKind

    private let _description: String?
    /// Description
    public var description: String {
        var res: String
        switch kind {
        case .missingSession:
            res = "Missing session"
        case .cantEstablish:
            res = "Can not create new session"
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

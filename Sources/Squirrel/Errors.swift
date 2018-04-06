//
//  Errors.swift
//  Squirrel
//
//  Created by Filip Klembara on 7/23/17.
//
//

import Foundation
import SquirrelJSON
import SquirrelCore

// MARK: - JSON error
extension JSONError: SquirrelError, HTTPErrorConvertible {
    /// JSONError as HTTP error
    public var asHTTPError: HTTPError {
        return HTTPError(status: .internalError, description: description)
    }
}

/// Data errors
public struct DataError: SquirrelError, HTTPErrorConvertible {
    /// Error kinds
    ///
    /// - dataEncodingError: Encoding filed
    /// - dataCodingError: Coding failed
    public enum ErrorKind {
        case dataEncodingError
        case dataCodingError(string: String)
    }

    init(kind: ErrorKind, description: String? = nil) {
        self.kind = kind
        _description = description
    }

    /// Error kind
    public let kind: ErrorKind
    private let _description: String?

    /// Error description
    public var description: String {
        var msg = ""
        if let tmpDescription = self._description {
            msg = tmpDescription
        } else {
            switch kind {
            case .dataEncodingError:
                msg = "Can not encode data to utf8 string."
            case .dataCodingError:
                msg = "Can not code to data."
            }
        }
        switch kind {
        case .dataCodingError(let string):
            msg += "\nString: '\(string)'"
        default:
            break
        }
        return msg
    }

    /// HTTPError representation
    public var asHTTPError: HTTPError {
        return HTTPError(status: .internalError, description: description)
    }
}

/// HTTP error
public struct HTTPError: Error, CustomStringConvertible, HTTPErrorConvertible {
    /// HTTP status
    public let status: HTTPStatus
    /// Description of error
    public let description: String

    /// Construct HTTPError with given code and description
    ///
    /// - Parameters:
    ///   - status: HTTP Status code
    ///   - description: Error description
    public init(status: HTTPStatus, description: String = "") {
        self.status = status
        self.description = description
    }

    /// Returns self
    public var asHTTPError: HTTPError {
        return self
    }
}

/// Route error
public struct RouteError: SquirrelError {
    /// Error kinds
    ///
    /// - addNodeError: Could not add node
    /// - methodHandlerOverwrite: Method at given node already exists
    public enum ErrorKind {
        case addNodeError
        case methodHandlerOverwrite
    }

    /// Error kind
    public let kind: ErrorKind

    /// Error description
    public var description: String {
        switch kind {
        case .addNodeError:
            return "Routes variable is empty."
        case .methodHandlerOverwrite:
            return "Trying to overwrite existing handler"
        }
    }
}

/// Request error
public struct RequestError: SquirrelError, HTTPErrorConvertible {
    /// Error kinds
    ///
    /// - unknownMethod: Unknown method
    /// - unknownProtocol: Unknown protocol
    /// - postBodyParseError: Can not decode body from POST request
    /// - headParseError: Can not parse head
    public enum ErrorKind {
        case unknownMethod(method: String)
        case unknownProtocol(prot: String)
        case postBodyParseError(errorString: String)
        case headParseError
    }

    init(kind: ErrorKind, description: String? = nil) {
        self.kind = kind
        _description = description
    }

    /// Error kind
    public let kind: ErrorKind
    private let _description: String?

    /// Error description
    public var description: String {
        var msg = ""
        if let tmpDescription = _description {
            msg = tmpDescription
        } else {
            switch kind {
            case .headParseError:
                msg = "Can not parse head"
            case .unknownMethod(let method):
                msg = "Unknown method \(method)"
            case .unknownProtocol(let prot):
                msg = "Unknown protocol \(prot)"
            case .postBodyParseError(let errorString):
                msg = "Can not parse: \(errorString)"
            }
        }
        return msg
    }

    /// HTTPError representation
    public var asHTTPError: HTTPError {
        switch kind {
        case .unknownMethod:
            return HTTPError(status: .notImplemented, description: description)
        case .unknownProtocol:
            return HTTPError(status: .httpVersionUnsupported, description: description)
        case .postBodyParseError, .headParseError:
            return HTTPError(status: .badRequest, description: description)
        }
    }
}

//
//  Errors.swift
//  Micros
//
//  Created by Filip Klembara on 7/23/17.
//
//

import Foundation
import NutView
import SquirrelJSONEncoding

//extension ViewError: SquirrelErrorProtocol {
//    public var asHTTPError: HTTPError {
//        switch kind {
//        case .notExists:
//            return HTTPError(status: .notFound, description: description)
//        case .getModif:
//            return HTTPError(status: .internalError, description: description)
//        }
//    }
//}

// TODO nutview errors

extension JSONError: AsHTTPProtocol {
    /// JSONError as HTTP error
    public var asHTTPError: HTTPError {
        return HTTPError(status: .internalError, description: message)
    }
}

/// Data errors
public struct DataError: Error, AsHTTPProtocol {
    enum ErrorKind {
        case dataEncodingError
        case dataCodingError(string: String)
    }

    init(kind: ErrorKind, message: String? = nil) {
        self.kind = kind
        _message = message
    }

    let kind: ErrorKind
    private let _message: String?

    var message: String {
        var msg = ""
        if let _message = self._message {
            msg = _message
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
        return HTTPError(status: .internalError, description: message)
    }
}

/// HTTP error
public struct HTTPError: Error, AsHTTPProtocol, CustomStringConvertible {
    let status: HTTPStatus
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


struct RouteError: Error, CustomStringConvertible {
    enum ErrorKind {
        case addNodeError
        case methodHandlerOverwrite
    }

    let kind: ErrorKind

    var description: String {
        switch kind {
        case .addNodeError:
            return "Routes variable is empty."
        case .methodHandlerOverwrite:
            return "Trying to overwrite existing handler"
        }
    }

}

struct RequestError: Error, AsHTTPProtocol {
    enum ErrorKind {
        case unseparatableHead
        case parseError(string: String, expectations: String)
        case unknownMethod(method: String)
        case unknownProtocol(prot: String)
        case postBodyParseError(errorString: String)
    }

    init(kind: ErrorKind, message: String? = nil) {
        self.kind = kind
        _message = message
    }

    let kind: ErrorKind
    private let _message: String?

    var message: String {
        var msg = ""
        if let _message = _message {
            msg = _message
        } else {
            switch kind {
            case .unseparatableHead:
                msg = "Can not separate head due to missing '\r\n\r\n' in data."
            case .parseError:
                msg = "Parse error."
            case .unknownMethod(let method):
                msg = "Unknown method \(method)"
            case .unknownProtocol(let prot):
                msg = "Unknown protocol \(prot)"
            case .postBodyParseError(let errorString):
                msg = "Can not parse: \(errorString)"
            }
        }
        switch kind {
        case .parseError(let string, let expectations):
            msg += "\nRecieved:\n\t\(string)\nExpectations:\n\t\(expectations)"
        default:
            break
        }
        return msg
    }

    var asHTTPError: HTTPError {
        switch kind {
        case .unseparatableHead:
            return HTTPError(status: .badRequest, description: "Can not separate head of request")
        case .parseError:
            return HTTPError(status: .badRequest, description: message)
        case .unknownMethod:
            return HTTPError(status: .notImplemented, description: message)
        case .unknownProtocol:
            return HTTPError(status: .httpVersionUnsupported, description: message)
        case .postBodyParseError:
            return HTTPError(status: .badRequest, description: message)
        }
    }
}

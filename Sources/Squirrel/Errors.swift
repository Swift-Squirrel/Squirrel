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

// MARK: - NutError
extension NutError: SquirrelErrorProtocol {
    public var asHTTPError: HTTPError {
        return HTTPError(status: .internalError, description: description)
    }
}

// MARK: - NutParserError
extension NutParserError: SquirrelErrorProtocol {
    public var asHTTPError: HTTPError {
        return HTTPError(status: .internalError, description: description)
    }
}

// MARK: - JSON error
extension JSONError: SquirrelErrorProtocol {
    /// JSONError as HTTP error
    public var asHTTPError: HTTPError {
        return HTTPError(status: .internalError, description: description)
    }
}

/// Data errors
public struct DataError: SquirrelErrorProtocol {
    public enum ErrorKind {
        case dataEncodingError
        case dataCodingError(string: String)
    }

    init(kind: ErrorKind, description: String? = nil) {
        self.kind = kind
        _description = description
    }

    public let kind: ErrorKind
    private let _description: String?

    public var description: String {
        var msg = ""
        if let _description = self._description {
            msg = _description
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
public struct HTTPError: SquirrelErrorProtocol {
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


public struct RouteError: SquirrelErrorProtocol {
    public enum ErrorKind {
        case addNodeError
        case methodHandlerOverwrite
    }

    public let kind: ErrorKind

    public var description: String {
        switch kind {
        case .addNodeError:
            return "Routes variable is empty."
        case .methodHandlerOverwrite:
            return "Trying to overwrite existing handler"
        }
    }

    public var asHTTPError: HTTPError {
        return HTTPError(status: .internalError, description: description)
    }

}

public struct RequestError: SquirrelErrorProtocol {
    public enum ErrorKind {
        case unseparatableHead
        case parseError(string: String, expectations: String)
        case unknownMethod(method: String)
        case unknownProtocol(prot: String)
        case postBodyParseError(errorString: String)
    }

    init(kind: ErrorKind, description: String? = nil) {
        self.kind = kind
        _description = description
    }

    public let kind: ErrorKind
    private let _description: String?

    public var description: String {
        var msg = ""
        if let _description = _description {
            msg = _description
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

    public var asHTTPError: HTTPError {
        switch kind {
        case .unseparatableHead:
            return HTTPError(status: .badRequest, description: "Can not separate head of request")
        case .parseError:
            return HTTPError(status: .badRequest, description: description)
        case .unknownMethod:
            return HTTPError(status: .notImplemented, description: description)
        case .unknownProtocol:
            return HTTPError(status: .httpVersionUnsupported, description: description)
        case .postBodyParseError:
            return HTTPError(status: .badRequest, description: description)
        }
    }
}

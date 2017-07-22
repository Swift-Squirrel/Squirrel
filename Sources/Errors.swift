//
//  Errors.swift
//  Micros
//
//  Created by Filip Klembara on 7/23/17.
//
//

import Foundation


protocol AsHTTPProtocol {
    var asHTTPError: HTTPError { get }
}

struct JSONError: Error, AsHTTPProtocol {
    enum ErrorKind {
        case parseError
        case encodeError
    }

    let kind: ErrorKind
    let message: String

    var asHTTPError: HTTPError {
        return HTTPError(status: .internalError, description: message)
    }
}

struct DataError: Error, AsHTTPProtocol {
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

    var asHTTPError: HTTPError {
        return HTTPError(status: .internalError, description: message)
    }
}

struct HTTPError: Error, AsHTTPProtocol, CustomStringConvertible {
    let status: HTTPStatus
    let description: String

    var asHTTPError: HTTPError {
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
        } 
    }
}

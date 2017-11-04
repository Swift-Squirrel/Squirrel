//
//  HTTPStatus.swift
//  SquirrelPackageDescription
//
//  Created by Filip Klembara on 11/2/17.
//

/// HTTP Statuses
public enum HTTPStatus: CustomStringConvertible {
    // 2xx
    case ok
    case created(location: String)
    case accepted
    case noContent
    case resetContent
    case partialContent

    // 3xx
    case movedPermanently(location: String)
    case found(location: String)
    case seeOther(location: String)
    case notModified
    case temporaryRedirect(location: String)
    case permanentRedirect(location: String)

    // 4xx
    case badRequest
    case unauthorized(wwwAuthenticate: String)
    case paymentRequired
    case forbidden
    case notFound
    case notAllowed(allowed: [RequestLine.Method])
    case notAcceptable
    case requestTimeout
    case conflict
    case gone
    case lengthRequired
    case preconditionFailed
    case unsupportedMediaType
    case failedDependency
    case tooManyRequests(retryAfter: String)

    // 5xx
    case internalError
    case notImplemented
    case serviceUnavailable(retryAfter: String)
    case httpVersionUnsupported

    /// HTTP status message
    public var message: String {
        switch self {
        case .ok:
            return "OK"
        case .created:
            return "Created"
        case .accepted:
            return "Accepted"
        case .noContent:
            return "No Content"
        case .resetContent:
            return "Reset Content"
        case .partialContent:
            return "Partial Content"

        case .movedPermanently:
            return "Moved Permanently"
        case .found:
            return "Found"
        case .seeOther:
            return "See Other"
        case .notModified:
            return "Not Modified"
        case .temporaryRedirect:
            return "Temporary Redirect"
        case .permanentRedirect:
            return "Permanent Redirect"

        case .badRequest:
            return "Bad Request"
        case .unauthorized:
            return "Unauthorized"
        case .paymentRequired:
            return "Payment Required"
        case .forbidden:
            return "Forbidden"
        case .notFound:
            return "Not Found"
        case .notAllowed:
            return "Method Not Allowed"
        case .notAcceptable:
            return "Not Acceptable"
        case .requestTimeout: // TODO connection: close
            return "Request Timeout"
        case .conflict:
            return "Conflict"
        case .gone:
            return "Gone"
        case .lengthRequired:
            return "Length Required"
        case .preconditionFailed:
            return "Precondition Failed"
        case .unsupportedMediaType:
            return "Unsupported Media Type"
        case .failedDependency:
            return "Failed Dependency"
        case .tooManyRequests:
            return "Too Many Requests"

        case .internalError:
            return "Internal Server Error"
        case .notImplemented:
            return "Not Implemented"
        case .serviceUnavailable:
            return "Service Unavailable"
        case .httpVersionUnsupported:
            return "Http Version Not Supported"
        }

    }

    /// HTTP status code
    public var code: UInt {
        switch self {
        case .ok:
            return 200
        case .created:
            return 201
        case .accepted:
            return 202
        case .noContent:
            return 204
        case .resetContent:
            return 205
        case .partialContent:
            return 206

        case .movedPermanently:
            return 301
        case .found:
            return 302
        case .seeOther:
            return 303
        case .notModified:
            return 304
        case .temporaryRedirect:
            return 307
        case .permanentRedirect:
            return 308

        case .badRequest:
            return 400
        case .unauthorized:
            return 401
        case .paymentRequired:
            return 402
        case .forbidden:
            return 403
        case .notFound:
            return 404
        case .notAllowed:
            return 405
        case .notAcceptable:
            return 406
        case .requestTimeout:
            return 408
        case .conflict:
            return 409
        case .gone:
            return 410
        case .lengthRequired:
            return 411
        case .preconditionFailed:
            return 412
        case .unsupportedMediaType:
            return 415
        case .failedDependency:
            return 424
        case .tooManyRequests:
            return 429

        case .internalError:
            return 500
        case .notImplemented:
            return 501
        case .serviceUnavailable:
            return 503
        case .httpVersionUnsupported:
            return 505
        }
    }

    /// Description
    public var description: String {
        let code = self.code
        let message = self.message
        return "\(code) \(message)"
    }
}

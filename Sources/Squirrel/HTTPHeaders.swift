//
//  HTTPHeaders.swift
//  Micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation

// swiftlint:disable nesting

/// HTTP Headers
public enum HTTPHeaders {

    /// HTTP protocol types
    ///
    /// - http11: HTTP/1.1
    public enum HTTPProtocol: String {
        case http11 = "HTTP/1.1"
    }
    /// `Content-Length`
    public static let contentLength = "Content-Length"
    /// `Location`
    public static let location = "Location"
    /// `Authenticate`
    public static let wwwAuthenticate = "WWW-Authenticate"
    /// `Retry`
    public static let retryAfter = "Retry-After"
    /// `Allow`
    public static let allow = "Allow"

    /// Content-Encoding values
    public enum Encoding {
        /// Content-Encoding
        public static let contentEncoding = "Content-Encoding"
        /// Accept-Encoding
        public static let acceptEncoding = "Accept-Encoding"
        /// Values
        ///
        /// - gzip: gzip
        public enum EncodingType: String {
            case gzip
            case deflate
        }
    }

    /// Content type
    public enum ContentType {
        /// `Content-Type`
        public static let contentType = "Content-Type"

        /// Image
        ///
        /// - png: `image/png`
        /// - jpeg: `image/jpeg`
        /// - svg: `image/svg+xml`
        public enum Image: String {
            case png = "image/png"
            case jpeg = "image/jpeg"
            case svg = "image/svg+xml"
        }

        /// Textx
        ///
        /// - html: `text/html`
        /// - plain: `text/plain`
        /// - css: `text/css`
        public enum Text: String {
            case html = "text/html"
            case plain = "text/plain"
            case css = "text/css"
        }

        /// Application
        ///
        /// - js: `application/javascript`
        /// - json: `application/json`
        /// - formUrlencoded: `application/x-www-form-urlencoded`
        public enum Application: String {
            case js = "application/javascript"
            case json = "application/json"
            case formUrlencoded = "application/x-www-form-urlencoded"
        }

        /// Multipart
        ///
        /// - formData: formData `multipart/form-data`
        public enum Multipart: String {
            case formData = "multipart/form-data"
        }
    }

    /// HTTP Method
    ///
    /// - post: POST
    /// - get: GET
    /// - put: PUT
    /// - delete: DELETE
    /// - head: HEAD
    /// - option: OPTIONS
    public enum Method: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
        case head = "HEAD"
        case options = "OPTIONS"
        case patch = "PATCH"
    }
}

/// HTTP Statuses
public enum HTTPStatus: CustomStringConvertible {
    // 2xx
    case ok
    case created(location: String)
    case accepted
    case noContent
    case resetContent

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
    case notAllowed(allowed: [HTTPHeaders.Method])
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
// swiftlint:enable nesting

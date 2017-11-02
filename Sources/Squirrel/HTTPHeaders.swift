//
//  HTTPHeaders.swift
//  Micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation

public enum RequestLine {
    /// HTTP Method
    ///
    /// - post: POST
    /// - get: GET
    /// - put: PUT
    /// - delete: DELETE
    /// - head: HEAD
    /// - option: OPTIONS
    public enum Method: String, CustomStringConvertible {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
        case head = "HEAD"
        case options = "OPTIONS"
        case patch = "PATCH"

        public var description: String {
            return rawValue
        }
    }

    public enum HTTPProtocol: String, CustomStringConvertible {
        case http11 = "1.1"

        init?(rawHTTPValue value: String) {
            guard value == "HTTP/1.1" else {
                return nil
            }

            self = .http11
        }

        /// - Note: Return Uppercased
        public var description: String {
            return "HTTP/\(rawValue)"
        }
    }

}

public enum HTTPHeader {
    case contentLength(size: Int)
    case contentEncoding(HTTPHeader.Encoding)
    case contentType(HTTPHeader.ContentType)
    case location(location: String)
}

extension HTTPHeader: Hashable {
    public var hashValue: Int {
        switch self {
        case .contentType:
            return 0
        case .contentEncoding:
            return 1
        case .contentLength:
            return 2
        case .location:
            return 3
        }
    }
    
    public static func ==(lhs: HTTPHeader, rhs: HTTPHeader) -> Bool {
        return lhs.description == rhs.description
    }
}

public extension HTTPHeader {
    enum Encoding: String, CustomStringConvertible {
        case gzip
        case deflate
        public var description: String {
            return self.rawValue
        }
    }

    enum ContentType: String, CustomStringConvertible {
        // Image
        case png
        case jpeg
        case svg = "svg+xml"

        //Text
        case html
        case plain
        case css

        // Applocation
        case js = "javascript"
        case json = "json"
        case formUrlencoded = "x-www-form-urlencoded"
        case forceDownload = "force-download"

        // multipart
        case formData = "form-data"

        public var description: String {
            let mime: String
            switch self {
            case .png, .jpeg, .svg:
                mime = "image"
            case .html, .plain, .css:
                mime = "text"
            case .js, .json, .formUrlencoded, .forceDownload:
                mime = "application"
            case .formData:
                mime = "multipart"
            }
            return "\(mime)/\(rawValue)"
        }
    }
}

extension HTTPHeader: CustomStringConvertible {
    public var description: String {
        let (key, value) = keyValue
        return "\(key): \(value)"
    }

    public var keyValue: (key: String, value: String) {
        let key: HTTPHeaderKey
        let value: String
        switch self {
        case .contentLength(let size):
            key = .contentLength
            value = size.description
        case .contentEncoding(let encoding):
            key = .contentEncoding
            value = encoding.description
        case .contentType(let type):
            key = .contentType
            value = type.description
        case .location(let location):
            key = .location
            value = location
        }
        return (key.description, value)
    }
}


public enum HTTPHeaderKey {
    case contentLength
    case location
    case wwwAuthenticate
    case retryAfter
    case allow
    case contentEncoding
    case acceptEncoding
    case contentType
    case setCookie
}

extension HTTPHeaderKey: CustomStringConvertible {
    public var description: String {
        switch self {
        case .contentLength:
            return "Content-Length"
        case .location:
            return "Location"
        case .wwwAuthenticate:
            return "WWW-Authenticate"
        case .retryAfter:
            return "Retry-After"
        case .allow:
            return "Allow"
        case .contentEncoding:
            return "Content-Encoding"
        case .acceptEncoding:
            return "Accept-Encoding"
        case .contentType:
            return "Content-Type"
        case .setCookie:
            return "Set-Cookie"
        }
    }
}

public func ==(lhs: String, rhs: HTTPHeader.ContentType) -> Bool {
    return lhs.lowercased() == rhs.description.lowercased()
}
public func ==(lhs: String, rhs: HTTPHeader.Encoding) -> Bool {
    return lhs.lowercased() == rhs.description.lowercased()
}
public func ==(lhs: String, rhs: HTTPHeaderKey) -> Bool {
    return lhs.lowercased() == rhs.description.lowercased()
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

//
//  HTTPHeaders.swift
//  Micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

/// Request-line in HTTP request
public enum RequestLine {
    /// HTTP Method
    ///
    /// - post: POST
    /// - get: GET
    /// - put: PUT
    /// - delete: DELETE
    /// - head: HEAD
    /// - option: OPTIONS
    /// - patch: PATCH
    public enum Method: String, CustomStringConvertible {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
        case head = "HEAD"
        case options = "OPTIONS"
        case patch = "PATCH"

        /// Uppercased rawValue
        public var description: String {
            return rawValue
        }
    }

    /// HTTP protocol
    ///
    /// - http11: 1.1
    public enum HTTPProtocol: String, CustomStringConvertible {
        case http11 = "1.1"

        init?(rawHTTPValue value: String) {
            guard value == "HTTP/1.1" else {
                return nil
            }

            self = .http11
        }


        /// Returns HTTP/\(rawValue)
        /// - Note: Value is uppercased
        public var description: String {
            return "HTTP/\(rawValue)"
        }
    }

}

/// HTTP header
///
/// - contentLength: Content length
/// - contentEncoding: Content encoding
/// - contentType: Content type
/// - location: Location
public enum HTTPHeader {
    case contentLength(size: Int)
    case contentEncoding(HTTPHeader.Encoding)
    case contentType(HTTPHeader.ContentType)
    case location(location: String)
    case range(UInt, UInt)
    case contentRange(start: UInt, end: UInt, from: UInt)
}

// MARK: - Hashable
extension HTTPHeader: Hashable {
    /// Hash value
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
        case .range:
            return 4
        case .contentRange:
            return 5
        }
    }

    /// Check string equality
    ///
    /// - Parameters:
    ///   - lhs: lhs
    ///   - rhs: rhs
    /// - Returns: `lhs.description == rhs.description`
    public static func == (lhs: HTTPHeader, rhs: HTTPHeader) -> Bool {
        return lhs.description == rhs.description
    }
}

// MARK: - Sub enums
public extension HTTPHeader {

    /// Encoding
    ///
    /// - gzip
    /// - deflate
    public enum Encoding: String, CustomStringConvertible {
        case gzip
        case deflate

        /// Returns raw value
        public var description: String {
            return self.rawValue
        }
    }

    /// Content type
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

        // video
        case mp4
        case ogg
        case mov = "quicktime"
        case webm
        case wmv = "x-ms-wmv"
        case avi = "x-msvideo"


        /// MIME representation
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
            case .mp4, .ogg, .mov, .webm, .wmv, .avi:
                mime = "video"
            }
            return "\(mime)/\(rawValue)"
        }
    }
}

// MARK: - Getting values from HTTPHeader
extension HTTPHeader: CustomStringConvertible {
    /// <key>: <value> description
    public var description: String {
        let (key, value) = keyValue
        return "\(key): \(value)"
    }

    /// Returns key and value
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
        case .range(let bottom, let top):
            key = .range
            value = "bytes=\(bottom)-\(top)"
        case .contentRange(let start, let end, let from):
            key = .contentRange
            value = "bytes \(start)-\(end)/\(from)"
        }
        return (key.description, value)
    }
}


/// HTTP header keys
///
/// - contentLength
/// - location
/// - wwwAuthenticate
/// - retryAfter
/// - allow
/// - contentEncoding
/// - acceptEncoding
/// - contentType
/// - setCookie
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
    case host
    case version
    case range
    case contentRange
    case acceptRanges
    case cacheControl
    case connection
}

// MARK: - CustomStringConvertible
extension HTTPHeaderKey: CustomStringConvertible {
    /// String representation of key
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
        case .host:
            return "Host"
        case .version:
            return "Version"
        case .range:
            return "Range"
        case .contentRange:
            return "Content-Range"
        case .acceptRanges:
            return "Accept-Ranges"
        case .cacheControl:
            return "Cache-Control"
        case .connection:
            return "Connection"
        }
    }
}


/// Check lowercased equality
///
/// - Parameters:
///   - lhs: lhs
///   - rhs: rhs
/// - Returns: If string representation in lowercased is same
public func == (lhs: String?, rhs: HTTPHeader.ContentType) -> Bool {
    return lhs?.lowercased() == rhs.description.lowercased()
}

/// Check lowercased equality
///
/// - Parameters:
///   - lhs: lhs
///   - rhs: rhs
/// - Returns: If string representation in lowercased is same
public func == (lhs: String?, rhs: HTTPHeader.Encoding) -> Bool {
    return lhs?.lowercased() == rhs.description.lowercased()
}
// TODO remove
//public func == (lhs: String?, rhs: HTTPHeader) -> Bool {
//    return lhs?.lowercased() == rhs.description.lowercased()
//}

/// Check lowercased equality
///
/// - Parameters
///   - lhs: lhs
///   - rhs: rhs
/// - Returns: If string representation in lowercased is same
public func == (lhs: String?, rhs: HTTPHeaderKey) -> Bool {
    return lhs?.lowercased() == rhs.description.lowercased()
}

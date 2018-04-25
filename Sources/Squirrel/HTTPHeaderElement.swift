//
//  HTTPHeaders.swift
//  Micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

/// HTTP header
///
/// - contentLength: Content length
/// - contentEncoding: Content encoding
/// - contentType: Content type
/// - location: Location
public enum HTTPHeaderElement {
    case contentLength(size: Int)
    case contentEncoding(HTTPHeaderElement.Encoding)
    case contentType(HTTPHeaderElement.ContentType)
    case location(location: String)
    case range(UInt, UInt)
    case contentRange(start: UInt, end: UInt, from: UInt)
    case connection(HTTPHeaderElement.Connection)
}

// MARK: - Hashable
extension HTTPHeaderElement: Hashable {
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
        case .connection:
            return 6
        }
    }

    /// Check string equality
    ///
    /// - Parameters:
    ///   - lhs: lhs
    ///   - rhs: rhs
    /// - Returns: `lhs.description == rhs.description`
    public static func == (lhs: HTTPHeaderElement, rhs: HTTPHeaderElement) -> Bool {
        return lhs.description == rhs.description
    }
}

// MARK: - Sub enums
public extension HTTPHeaderElement {

    /// Connection
    ///
    /// - keepAlive
    /// - close
    public enum Connection: String, CustomStringConvertible {
        /// rawValue of case
        public var description: String {
            return rawValue
        }

        case keepAlive = "keep-alive"
        case close
    }

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

        // Application
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
extension HTTPHeaderElement: CustomStringConvertible {
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
        case .connection(let con):
            key = .connection
            value = con.description
        }
        return (key.description, value)
    }
}

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
        case http11 = "HTTP/1.1"

        init?(rawHTTPValue value: String) {
            guard value == "HTTP/1.1" else {
                return nil
            }

            self = .http11
        }

        /// Returns `rawValue`
        /// - Note: Value is uppercased
        public var description: String {
            return rawValue
        }
    }
}

/// Check lowercased equality
///
/// - Parameters:
///   - lhs: lhs
///   - rhs: rhs
/// - Returns: If string representation in lowercased is same
public func == (lhs: String?, rhs: HTTPHeaderElement.ContentType) -> Bool {
    return lhs?.lowercased() == rhs.description.lowercased()
}

/// Check lowercased equality
///
/// - Parameters:
///   - lhs: lhs
///   - rhs: rhs
/// - Returns: If string representation in lowercased is same
public func == (lhs: String?, rhs: HTTPHeaderElement.Connection) -> Bool {
    return lhs?.lowercased() == rhs.description.lowercased()
}

/// Check lowercased equality
///
/// - Parameters:
///   - lhs: lhs
///   - rhs: rhs
/// - Returns: If string representation in lowercased is same
public func == (lhs: String?, rhs: HTTPHeaderElement.Encoding) -> Bool {
    return lhs?.lowercased() == rhs.description.lowercased()
}

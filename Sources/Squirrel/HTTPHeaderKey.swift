//
//  HTTPHeaderKey.swift
//  Squirrel
//
//  Created by Filip Klembara on 11/4/17.
//

/// HTTP header keys
public enum HTTPHeaderKey {
    case accept
    case acceptCharset
    case acceptEncoding
    case acceptLanguage
    case acceptRanges
    case accessControlAllowCredentials
    case accessControlAllowHeaders
    case accessControlAllowMethods
    case accessControlAllowOrigin
    case accessControlExposeHeaders
    case accessControlMaxAge
    case accessControlRequestHeaders
    case accessControlRequestMethod
    case age
    case allow
    case authorization
    case cacheControl
    case connection
    case contentDisposition
    case contentEncoding
    case contentLanguage
    case contentLength
    case contentLocation
    case contentRange
    case contentSecurityPolicy
    case contentSecurityPolicyReportOnly
    case contentTransferEncoding
    case contentType
    case cookie
    case dnt
    case date
    case eTag
    case expect
    case expires
    case forwarded
    case from
    case host
    case ifMatch
    case ifModifiedSince
    case ifNoneMatch
    case ifRange
    case ifUnmodifiedSince
    case lastModified
    case location
    case origin
    case pragma
    case proxyAuthenticate
    case proxyAuthorization
    case publicKeyPins
    case publicKeyPinsReportOnly
    case range
    case referer
    case referrerPolicy
    case retryAfter
    case server
    case setCookie
    case sourceMap
    case strictTransportSecurity
    case tk
    case trailer
    case transferEncoding
    case upgradeInsecureRequests
    case userAgent
    case vary
    case version
    case via
    case wwwAuthenticate
    case warning
    case xContentTypeOptions
    case xDNSPrefetchControl
    case xForwardedFor
    case xForwardedHost
    case xForwardedProto
    case xFrameOptions
    case xXSSProtection
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
        case .accept:
            return "Accept"
        case .acceptCharset:
            return "Accept-Charset"
        case .acceptLanguage:
            return "Accept-Language"
        case .accessControlAllowCredentials:
            return "Access-Control-Allow-Credentials"
        case .accessControlAllowHeaders:
            return "Access-Control-Allow-Headers"
        case .accessControlAllowMethods:
            return "Access-Control-Allow-Methods"
        case .accessControlAllowOrigin:
            return "Access-Control-Allow-Origin"
        case .accessControlExposeHeaders:
            return "Access-Control-Expose-Headers"
        case .accessControlMaxAge:
            return "Access-Control-Max-Age"
        case .accessControlRequestHeaders:
            return "Access-Control-Request-Headers"
        case .accessControlRequestMethod:
            return "Access-Control-Request-Method"
        case .age:
            return "Age"
        case .authorization:
            return "Authorization"
        case .contentDisposition:
            return "Content-Disposition"
        case .contentLanguage:
            return "Content-Language"
        case .contentLocation:
            return "Content-Location"
        case .contentSecurityPolicy:
            return "Content-Security-Policy"
        case .contentSecurityPolicyReportOnly:
            return "Content-Security-Policy-Report-Only"
        case .contentTransferEncoding:
            return "Content-Transfer-Encoding"
        case .cookie:
            return "Cookie"
        case .dnt:
            return "DNT"
        case .date:
            return "Date"
        case .eTag:
            return "ETag"
        case .expect:
            return "Expect"
        case .expires:
            return "Expires"
        case .forwarded:
            return "Forwarded"
        case .from:
            return "From"
        case .ifMatch:
            return "If-Match"
        case .ifModifiedSince:
            return "If-Modified-Since"
        case .ifNoneMatch:
            return "If-None-Match"
        case .ifRange:
            return "If-Range"
        case .ifUnmodifiedSince:
            return "If-Unmodified-Since"
        case .lastModified:
            return "Last-Modified"
        case .origin:
            return "Origin"
        case .pragma:
            return "Pragma"
        case .proxyAuthenticate:
            return "Proxy-Authenticate"
        case .proxyAuthorization:
            return "Proxy-Authorization"
        case .publicKeyPins:
            return "Public-Key-Pins"
        case .publicKeyPinsReportOnly:
            return "Public-Key-Pins-Report-Only"
        case .referer:
            return "Referer"
        case .referrerPolicy:
            return "Referrer-Policy"
        case .server:
            return "Server"
        case .sourceMap:
            return "SourceMap"
        case .strictTransportSecurity:
            return "Strict-Transport-Security"
        case .tk:
            return "Tk"
        case .trailer:
            return "Trailer"
        case .transferEncoding:
            return "Transfer-Encoding"
        case .upgradeInsecureRequests:
            return "Upgrade-Insecure-Requests"
        case .userAgent:
            return "User-Agent"
        case .vary:
            return "Vary"
        case .via:
            return "Via"
        case .warning:
            return "Warning"
        case .xContentTypeOptions:
            return "X-Content-Type-Options"
        case .xDNSPrefetchControl:
            return "X-DNS-Prefetch-Control"
        case .xForwardedFor:
            return "X-Forwarded-For"
        case .xForwardedHost:
            return "X-Forwarded-Host"
        case .xForwardedProto:
            return "X-Forwarded-Proto"
        case .xFrameOptions:
            return "X-Frame-Options"
        case .xXSSProtection:
            return "X-XSS-Protection"
        }
    }
}


/// Check lowercased equality
///
/// - Parameters
///   - lhs: lhs
///   - rhs: rhs
/// - Returns: If string representation in lowercased is same
public func == (lhs: String?, rhs: HTTPHeaderKey) -> Bool {
    return lhs?.lowercased() == rhs.description.lowercased()
}

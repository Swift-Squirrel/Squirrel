//
//  HTTPHead.swift
//  SquirrelPackageDescription
//
//  Created by Filip Klembara on 11/2/17.
//

import Foundation

/// HTTP head
public struct HTTPHead {
    /// Inner dictionary type
    public typealias DictionaryType = [String: String]

    /// Cookies
    public internal(set) var cookies: [String: String] = [:]

    private var headers: DictionaryType

    /// Constructs from key value dictionary
    ///
    /// - Parameter headers: New headers
    public init(headers: [String: String] = [:]) {
        self.headers = [:]
        for (key, value) in headers {
            self[key] = value
        }
    }

    /// Constructs from key value dictionary
    ///
    /// - Parameter headers: New headers
    public init(headers: [HTTPHeaderKey: String]) {
        self.headers = [:]
        for (key, value) in headers {
            self[key] = value
        }
    }

    /// Constructs from HTTPHeader array
    ///
    /// - Parameter headers: New headers
    public init(headers: [HTTPHeader]) {
        self.headers = [:]
        for head in headers {
            set(to: head)
        }
    }

    func makeHeader(httpVersion: RequestLine.HTTPProtocol, status: HTTPStatus) -> Data {
        var header = httpVersion.rawValue + " " + status.description + "\r\n"

        for (key, value) in self {
            header += key + ": " + value + "\r\n"
        }

        for (key, value) in cookies {
            header += "\(HTTPHeaderKey.setCookie): \(key)=\(value)\r\n"
        }
        header += "\r\n"
        return header.data(using: .utf8)!
    }
}

// MARK: - Collection
extension HTTPHead: Collection {
    /// Index type
    public typealias Index = DictionaryType.Index
    /// Element type
    public typealias Element = DictionaryType.Element

    /// Start index
    public var startIndex: Index { return headers.startIndex }
    /// End index
    public var endIndex: Index { return headers.endIndex }

    /// Index subscript
    ///
    /// - Parameter index: Index
    public subscript(index: Index) -> (key: String, value: String) {
        get { return headers[index] }
    }

    /// Returns next index
    ///
    /// - Parameter index: Index
    /// - Returns: Index after passed index
    public func index(after index: DictionaryType.Index) -> DictionaryType.Index {
        return headers.index(after: index)
    }
}

// MARK: - Subscripts
extension HTTPHead {
    /// String key subscript (case-insensitive)
    ///
    /// - Parameter key: Key
    public subscript(key: String) -> String? {
        set {
            headers[key.lowercased()] = newValue
        }
        get {
            return headers[key.lowercased()]
        }
    }

    /// HTTPHeaderKey subscript
    ///
    /// - Parameter key: Key
    public subscript(key: HTTPHeaderKey) -> String? {
        set {
            headers[key.description.lowercased()] = newValue
        }
        get {
            return headers[key.description.lowercased()]
        }
    }

    /// Set header
    ///
    /// - Parameter keyValue: HTTPHeader key value
    public mutating func set(to keyValue: HTTPHeader) {
        let (key, value) = keyValue.keyValue
        headers[key.lowercased()] = value
    }
}

// MARK: - ExpressibleByDictionaryLiteral
extension HTTPHead: ExpressibleByDictionaryLiteral {
    /// Constructs from dictionary literal
    ///
    /// - Parameter elements: dictionary literal
    public init(dictionaryLiteral elements: (String, String)...) {
        self.headers = [:]
        for (key, value) in elements {
            headers[key.lowercased()] = value
        }
    }
}

// MARK: - ExpressibleByArrayLiteral
extension HTTPHead: ExpressibleByArrayLiteral {
    /// Constructs from array literal
    ///
    /// - Parameter elements: Array literal
    public init(arrayLiteral elements: HTTPHeader...) {
        self.headers = [:]
        for head in elements {
            set(to: head)
        }
    }
}

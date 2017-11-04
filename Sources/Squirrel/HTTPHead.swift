//
//  HTTPHead.swift
//  SquirrelPackageDescription
//
//  Created by Filip Klembara on 11/2/17.
//

public struct HTTPHead {
    public typealias DictionaryType = [String: String]
    private var headers: DictionaryType

    public init(headers: [String: String] = [:]) {
        self.headers = headers
    }

    public init(headers: [HTTPHeaderKey: String]) {
        self.headers = [:]
        for (key, value) in headers {
            self[key] = value
        }
    }

    public init(headers: [HTTPHeader]) {
        self.headers = [:]
        for head in headers {
            set(to: head)
        }
    }
}

extension HTTPHead: Collection {
    public typealias Index = DictionaryType.Index
    public typealias Element = DictionaryType.Element

    public var startIndex: Index { return headers.startIndex }
    public var endIndex: Index { return headers.endIndex }
    // Required subscript, based on a dictionary index
    public subscript(index: Index) -> (key: String, value: String) {
        get { return headers[index] }
    }
    // Method that returns the next index when iterating
    public func index(after index: DictionaryType.Index) -> DictionaryType.Index {
        return headers.index(after: index)
    }
}

extension HTTPHead {
    public subscript(key: String) -> String? {
        set {
            headers[key.lowercased()] = newValue
        }
        get {
            return headers[key.lowercased()]
        }
    }

    public subscript(key: HTTPHeaderKey) -> String? {
        set {
            headers[key.description.lowercased()] = newValue
        }
        get {
            return headers[key.description.lowercased()]
        }
    }

    public mutating func set(to keyValue: HTTPHeader) {
        let (key, value) = keyValue.keyValue
        headers[key] = value
    }
}

extension HTTPHead: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, String)...) {
        self.headers = [:]
        for (key, value) in elements {
            headers[key] = value
        }
    }
}

extension HTTPHead: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: HTTPHeader...) {
        self.headers = [:]
        for head in elements {
            set(to: head)
        }
    }
}

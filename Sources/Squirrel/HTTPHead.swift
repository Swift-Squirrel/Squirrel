//
//  HTTPHead.swift
//  SquirrelPackageDescription
//
//  Created by Filip Klembara on 11/2/17.
//

struct HTTPHead {
    typealias DictionaryType = [String: String]
    private var headers: DictionaryType

    init(headers: [String: String] = [:]) {
        self.headers = headers
    }

    init(headers: [HTTPHeaderKey: String]) {
        self.headers = [:]
        for (key, value) in headers {
            self[key] = value
        }
    }

    init(headers: [HTTPHeader]) {
        self.headers = [:]
        for head in headers {
            set(to: head)
        }
    }
}

extension HTTPHead: Collection {
    typealias Index = DictionaryType.Index
    typealias Element = DictionaryType.Element

    var startIndex: Index { return headers.startIndex }
    var endIndex: Index { return headers.endIndex }
    // Required subscript, based on a dictionary index
    subscript(index: Index) -> (key: String, value: String) {
        get { return headers[index] }
    }
    // Method that returns the next index when iterating
    func index(after index: DictionaryType.Index) -> DictionaryType.Index {
        return headers.index(after: index)
    }
}

extension HTTPHead {
    subscript(key: String) -> String? {
        set {
            headers[key.lowercased()] = newValue
        }
        get {
            return headers[key.lowercased()]
        }
    }

    subscript(key: HTTPHeaderKey) -> String? {
        set {
            headers[key.description.lowercased()] = newValue
        }
        get {
            return headers[key.description.lowercased()]
        }
    }

    mutating func set(to keyValue: HTTPHeader) {
        let (key, value) = keyValue.keyValue
        headers[key] = value
    }
}

extension HTTPHead: ExpressibleByDictionaryLiteral {
    init(dictionaryLiteral elements: (String, String)...) {
        self.headers = [:]
        for (key, value) in elements {
            headers[key] = value
        }
    }
}

extension HTTPHead: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: HTTPHeader...) {
        self.headers = [:]
        for head in elements {
            set(to: head)
        }
    }
}

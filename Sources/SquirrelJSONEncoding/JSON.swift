//
//  JSON.swift
//  SquirrelJSONEncoding
//
//  Created by Filip Klembara on 9/3/17.
//

/// JSON Representation
public struct JSON {

    private let data: Any?

    /// Construct from JSON String
    ///
    /// - Parameter string: String containing JSON
    /// - Throws: Parsing errors
    public init(string: String) throws {
        guard let data = JSONCoding.toJSON(json: string) else {
            throw JSONError(kind: .parseError, description: "Corrupted content")
        }
        self.data = data
    }

    /// Construct from `Any` object
    ///
    /// - Parameter data: Anything as body of JSON
    public init(from data: Any?) {
        self.data = data
    }
}

// MARK: - String
public extension JSON {
    /// String
    public var string: String? {
        guard let data = self.data else {
            return nil
        }
        guard let str = data as? String else {
            return nil
        }
        return str
    }

    /// String value (default "")
    public var stringValue: String {
        return string ?? ""
    }
}

// MARK: - Dictionary
extension JSON {
    /// Dictionary
    public var dictionary: [String: JSON]? {
        guard let dic = data as? [String: Any] else {
            return nil
        }
        var res: [String: JSON] = [:]
        for (key, value) in dic {
            res[key] = JSON(from: value)
        }
        return res
    }

    /// Dictionary value (if nil return [:])
    public var dictionaryValue: [String: JSON] {
        return dictionary ?? [:]
    }

    /// Returns JSON value for given Key
    ///
    /// - Note: If value for given key does not exists
    ///     this will return `JSON(from: nil)`
    ///
    /// - Parameter key: Key
    public subscript(key: String) -> JSON {
        if let dic = dictionary, let value = dic[key] {
            return value
        }
        return JSON(from: nil)
    }
}

// MARK: - Array
public extension JSON {
    /// Array
    public var array: [JSON]? {
        guard let data = self.data else {
            return nil
        }

        guard let arr = data as? [Any] else {
            return nil
        }

        return arr.map({ JSON(from: $0) })
    }

    /// Array (if nil returns [])
    public var arrayValue: [JSON] {
        return array ?? []
    }

    /// Returns JSON value for given Key
    ///
    /// - Note: When value for index does not exists return `JSON(from: nil)`
    ///
    /// - Parameter index: index
    public subscript(index: Int) -> JSON {
        guard index >= 0 else {
            return JSON(from: nil)
        }
        guard let arr = array else {
            return JSON(from: nil)
        }
        guard index < arr.count else {
            return JSON(from: nil)
        }
        return arr[index]
    }
}

// MARK: - Int
extension JSON {
    /// Int
    public var int: Int? {
        guard let data = self.data else {
            return nil
        }

        return data as? Int
    }

    /// Int (if nil returns 0)
    public var intValue: Int {
        return int ?? 0
    }
}

// MARK: - Double
extension JSON {
    /// Double
    public var double: Double? {
        guard let data = self.data else {
            return nil
        }

        return data as? Double
    }

    /// Double (if nil return 0.0)
    public var doubleValue: Double {
        return double ?? 0.0
    }
}

// MARK: - Bool
extension JSON {
    /// Bool
    public var bool: Bool? {
        guard let data = self.data else {
            return nil
        }

        return data as? Bool
    }

    /// Bool (if nil returns false)
    public var boolValue: Bool {
        return bool ?? false
    }
}

// MARK: - Any
public extension JSON {
    /// Any
    public var any: Any? {
        return data
    }
}

// MARK: - Additive functions
public extension JSON {
    /// Check if JSON represents nil
    public var isNil: Bool {
        return data == nil
    }

    /// Check if value is empty
    ///
    /// - Note: When self does not represents Array or Dictionary
    ///     return false, if represents nil returns true
    public var isEmpty: Bool {
        guard let data = self.data else {
            return true
        }

        switch data {
        case let arr as [Any]:
            return arr.isEmpty
        case let dic as [String: Any]:
            return dic.isEmpty
        default:
            return false
        }
    }
}

extension JSON: Equatable {
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable operator_whitespace
    /// Check JSONs for Equality
    ///
    /// - Parameters:
    ///   - lhs: left JSON
    ///   - rhs: right JSON
    /// - Returns: True if JSONs are equal
    public static func ==(lhs: JSON, rhs: JSON) -> Bool {

        if lhs.data == nil && rhs.data == nil {
            return true
        }

        guard let ldata = lhs.data else {
            return false
        }

        guard let rdata = rhs.data else {
            return false
        }
        switch ldata {
        case let int as Int:
            return int == rdata as? Int
        case let double as Double:
            return double == rdata as? Double
        case let bool as Bool:
            return bool == rdata as? Bool
        case let string as String:
            return string == rdata as? String
        case is [Any]:
            let larr = lhs.arrayValue
            let rarr = rhs.arrayValue
            guard larr.count == rarr.count else {
                return false
            }
            for index in 0..<larr.count {
                guard larr[index] == rarr[index] else {
                    return false
                }
            }
            return true
        case is [String: Any]:
            let ldir = lhs.dictionaryValue
            let rdir = rhs.dictionaryValue

            guard rdir.count == ldir.count else {
                return false
            }

            for (key, value) in ldir {
                guard rdir[key] == value else {
                    return false
                }
            }
            return true
        default:
            return false
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable operator_whitespace
}

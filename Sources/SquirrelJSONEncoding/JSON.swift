//
//  JSON.swift
//  SquirrelJSONEncoding
//
//  Created by Filip Klembara on 9/3/17.
//

// swiftlint:disable file_length

import Foundation

/// JSON Representation
public struct JSON {

    fileprivate enum ValueType {
        case string(str: String)
        case dictionary(dic: [String: JSON])
        case array(arr: [JSON])
        case int(int: Int)
        case double(double: Double)
        case bool(bool: Bool)
        case date(date: Date)
        case `nil`
    }

    private var type: ValueType

    /// Construct from JSON String
    ///
    /// - Parameter string: String containing JSON
    /// - Throws: Parsing errors
    public init(json: String) throws {
        guard let data = JSONCoding.toJSON(json: json) else {
            throw JSONError(kind: .parseError, description: "Corrupted content")
        }
        if let dic = data as? [String: Any] {
            guard let jsonDic = JSON(dictionary: dic)?.dictionary else {
                throw JSONError(kind: .parseError, description: "Not valid dictionary")
            }
            type = .dictionary(dic: jsonDic)
        } else if let arr = data as? [Any] {
            guard let jsonArr = JSON(array: arr)?.array else {
                throw JSONError(kind: .parseError, description: "Not valid array")
            }
            type = .array(arr: jsonArr)
        } else {
            throw JSONError(kind: .parseError, description: "Not valid content")
        }
    }

    /// Construct null JSON value
    public init() {
        type = .nil
    }

    /// Construct from JSON
    ///
    /// - Parameter json: JSON
    public init(_ json: JSON) {
        type = json.type
    }

    /// Construct from any value
    ///
    /// - Note: If `any` is incompatible type returns nil
    ///
    /// - Parameter any: Value
    public init?(from any: Any?) {
        // swiftlint:disable:previous cyclomatic_complexity

        if let any = any {
            switch any {
            case let dictionary as [String: JSON]:
                self.init(dictionary)
            case let dictionary as [String: Any]:
                self.init(dictionary: dictionary)
            case let array as [JSON]:
                self.init(array)
            case let array as [Any]:
                self.init(array: array)
            case let string as String:
                self.init(string)
            case let int as Int:
                self.init(int)
            case let double as Double:
                self.init(double)
            case let bool as Bool:
                self.init(bool)
            case let json as JSON:
                self.init(json)
            default:
                return nil
            }
        } else {
            self.init()
        }
    }
}

// MARK: - String
public extension JSON {

    /// Construct from string
    ///
    /// - Parameter string: String value
    public init(_ string: String) {
        type = .string(str: string)
    }

    /// String
    public var string: String? {
        guard case let ValueType.string(str) = type else {
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

    /// Constructs from dictionary
    ///
    /// - Parameter dictionary: Dictionary value
    public init(_ dictionary: [String: JSON]) {
        type = .dictionary(dic: dictionary)
    }

    /// Constructs from dictionary
    ///
    /// - Parameter dictionary: Dictionary value
    public init?(dictionary: [String: Any]) {
        var res = [String: JSON]()
        for (key, value) in dictionary {
            guard let value = JSON(from: value) else {
                return nil
            }
            res[key] = value
        }
        type = .dictionary(dic: res)
    }

    /// Dictionary
    public var dictionary: [String: JSON]? {
        guard case let .dictionary(dic) = type else {
            return nil
        }
        return dic
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
        return JSON(from: nil)!
    }
}

// MARK: - Array
public extension JSON {

    /// Constructs from Array
    ///
    /// - Parameter array: Array value
    public init(_ array: [JSON]) {
        type = .array(arr: array)
    }

    /// Constructs from Array
    ///
    /// - Parameter array: Array value
    public init?(array: [Any]) {
        var res = [JSON]()
        for element in array {
            guard let element = JSON(from: element) else {
                return nil
            }
            res.append(element)
        }
        type = .array(arr: res)
    }

    /// Array
    public var array: [JSON]? {
        guard case let .array(arr) = type else {
            return nil
        }
        return arr
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
            return JSON(from: nil)!
        }
        guard let arr = array else {
            return JSON(from: nil)!
        }
        guard index < arr.count else {
            return JSON(from: nil)!
        }
        return arr[index]
    }
}

// MARK: - Int
extension JSON {
    /// Constructs from integer value
    ///
    /// - Parameter int: Integer value
    public init(_ int: Int) {
        type = .int(int: int)
    }

    /// Int
    public var int: Int? {
        guard case let .int(intValue) = type else {
            return nil
        }
        return intValue
    }

    /// Int (if nil returns 0)
    public var intValue: Int {
        return int ?? 0
    }
}

// MARK: - Double
extension JSON {
    /// Constructs from double value
    ///
    /// - Parameter double: Double value
    public init(_ double: Double) {
        type = .double(double: double)
    }
    /// Double
    public var double: Double? {
        guard case let .double(doubleVal) = type else {
            return nil
        }
        return doubleVal
    }

    /// Double (if nil return 0.0)
    public var doubleValue: Double {
        return double ?? 0.0
    }
}

// MARK: - Bool
extension JSON {
    /// Constructs from Bool value
    ///
    /// - Parameter bool: Bool value
    public init(_ bool: Bool) {
        type = .bool(bool: bool)
    }
    /// Bool
    public var bool: Bool? {
        switch type {
        case .bool(let boolVal):
            return boolVal
        case .int(let intVal):
            switch intVal {
            case 0: return false
            case 1: return true
            default: return nil
            }
        default:
            return nil
        }
    }

    /// Bool (if nil returns false)
    public var boolValue: Bool {
        return bool ?? false
    }
}

// MARK: - Date
extension JSON {
    /// Constructs from date value
    ///
    /// - Parameter date: Date value
    public init(_ date: Date) {
        type = .date(date: date)
    }
    /// Bool
    public var date: Date? {
        guard case let .date(dateVal) = type else {
            return nil
        }

        return dateVal
    }

    /// Bool (if nil returns Date())
    public var dateValue: Date {
        return date ?? Date()
    }
}

// MARK: - Additive functions
public extension JSON {
    /// Check if JSON represents nil
    public var isNil: Bool {
        switch type {
        case .nil:
            return true
        default:
            return false
        }
    }

    /// Check if value is empty
    ///
    /// - Note: When self does not represents Array or Dictionary
    ///     return false, if represents nil returns true
    public var isEmpty: Bool {
        if case .nil = type {
            return true
        }

        switch type {
        case .array(let arr):
            return arr.isEmpty
        case .dictionary(let dic):
            return dic.isEmpty
        default:
            return false
        }
    }

    /// Decode data to JSON
    ///
    /// - Parameter data: All important data in JSON data format
    /// - Returns: JSON or nil on error
    public static func decode(from data: Data) -> JSON? {
        let decoder = JSONDecoder()
        return try? decoder.decode(self, from: data)
    }

    /// Encoded JSON to Data or nil on error
    public var encode: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
}

extension JSON: Equatable {
    /// Check JSONs for Equality
    ///
    /// - Note: If JSONS are Codable this return false
    ///
    /// - Parameters:
    ///   - lhs: left JSON
    ///   - rhs: right JSON
    /// - Returns: True if JSONs are equal
    public static func ==(lhs: JSON, rhs: JSON) -> Bool {
        // swiftlint:disable:previous operator_whitespace

        if case .nil = lhs.type, case .nil = rhs.type {
            return true
        }

        if case .nil = lhs.type {
            return false
        }

        if case .nil = rhs.type {
            return false
        }

        switch (lhs.type, rhs.type) {
        case let (.int(lint), .int(rint)):
            return lint == rint
        case let (.double(ldouble), .double(rdouble)):
            return ldouble == rdouble
        case let (.bool(lbool), .bool(rbool)):
            return lbool == rbool
        case let (.string(lstring), .string(rstring)):
            return lstring == rstring
        case let (.array(larr), .array(rarr)):
            return larr == rarr
        case let (.dictionary(ldic), .dictionary(rdic)):
            return ldic == rdic
        default:
            return false
        }
    }
}

// MARK: - JSON Codable
extension JSON: Codable {
    /// JSON decoder
    ///
    /// - Parameter decoder: Decoder
    /// - Throws: `JSONError(kind: .encodeError, description: "Could not encode")`
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? values.decode(String.self, forKey: .string) {
            type = .string(str: value)
            return
        }
        if let value = try? values.decode([String: JSON].self, forKey: .dictionary) {
            type = .dictionary(dic: value)
            return
        }
        if let value = try? values.decode([JSON].self, forKey: .array) {
            type = .array(arr: value)
            return
        }
        if let value = try? values.decode(Int.self, forKey: .int) {
            type = .int(int: value)
            return
        }
        if let value = try? values.decode(Double.self, forKey: .double) {
            type = .double(double: value)
            return
        }
        if let value = try? values.decode(Bool.self, forKey: .bool) {
            type = .bool(bool: value)
            return
        }
        if let value = try? values.decode(Date.self, forKey: .date) {
            type = .date(date: value)
            return
        }
        if values.contains(.nil) {
            type = .nil
        }
        throw JSONError(kind: .encodeError, description: "Could not encode")
    }

    /// JSON Encoder
    ///
    /// - Parameter encoder: Encoder
    /// - Throws: encode errors
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch type {
        case .string(let str):
            try container.encode(str, forKey: .string)
        case .dictionary(let dic):
            try container.encode(dic, forKey: .dictionary)
        case .array(let arr):
            try container.encode(arr, forKey: .array)
        case .int(let int):
            try container.encode(int, forKey: .int)
        case .double(let double):
            try container.encode(double, forKey: .double)
        case .bool(let bool):
            try container.encode(bool, forKey: .bool)
        case .date(let date):
            try container.encode(date, forKey: .date)
        case .nil:
            try container.encode("nil", forKey: .nil)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case string
        case dictionary
        case array
        case int
        case double
        case bool
        case `nil`
        case date
    }
}

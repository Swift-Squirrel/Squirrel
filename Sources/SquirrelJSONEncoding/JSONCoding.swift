//
//  JSONCoding.swift
//  Micros
//
//  Created by Filip Klembara on 7/17/17.
//
//

import Foundation
import SquirrelConnector

/// JSON Coding struct
public struct JSONCoding {
    private init() {
    }

    /// Encode object to JSON Any?
    ///
    /// - Note: If object is array this will return Dictionary with one key value pair
    ///     where key is plural of object type and value is given object
    ///
    /// - Parameter object: object to serialize
    /// - Returns: result of serializing
    public static func encodeSerializeJSON<T>(object: T) -> Any? {
        let desc = Mirror(reflecting: object).description
        if desc.hasPrefix("Mirror for Array<") {
            var name = desc.components(separatedBy: "<")[1]
            name = name[..<name.index(before: name.endIndex)] + "s"

            let first = name.lowercased()[..<name.index(after: name.startIndex)]
            let rest = String(name.dropFirst())
            name = "\(first)\(rest)"
            return encode(object: [name: object])
        }
        return encode(object: object)
    }

    /// Encode object to JSON as Data
    ///
    /// - Parameter object: Object to serialize
    /// - Returns: Data representation of JSON
    /// - Throws: `JSONError`
    public static func encodeDataJSON<T>(object: T) throws -> Data {
        if let data = encodeSerializeJSON(object: object) {
            return try dataSerialization(data: data)
        } else {
            throw JSONError(kind: .encodeError, description: "Can not encode object to JSON.")
        }
    }

    private static func dataSerialization(data: Any) throws -> Data {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: data,
            options: []
            ) {
            return theJSONData
        } else {
            throw JSONError(kind: .parseError, description: "Can not serialize data to json format.")
        }
    }

    /// Check if given JSON is valid
    ///
    /// - Parameter json: json to check
    /// - Returns: If valid
    public static func isValid(json: String) -> Bool {
        return toJSON(json: json) != nil
    }

    /// Convert JSON as String to Any?
    ///
    /// - Parameter string: json to decode
    /// - Returns: Representation of JSON
    public static func toJSON(json string: String) -> Any? {
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else {
            return false
        }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }

    /// Encode object to String JSON
    ///
    /// - Parameter object: Object to encode
    /// - Returns: String representation of JSON from given object
    /// - Throws: JSONError
    public static func encodeJSON<T>(object: T) throws -> String {
        let theJSONData = try encodeDataJSON(object: object)
        if let theJSONText = String(data: theJSONData, encoding: .utf8) {
            return theJSONText
        } else {
            throw JSONError(kind: .dataEncodingError, description: "Can not encode data")
        }
    }

    /// Encode object to json representation
    ///
    /// - Parameter object: object to encode
    /// - Returns: json representation or nil otherwise
    public static func encode<T>(object: T) -> Any? {
        var res: [String: Any] = [:]
        if object is Primitive {
            return object
        } else if let arr = object as? [Any] {
            return arr.map({ encode(object: $0 ) })
        } else if let dic = object as? [String: Any] {
            for (k, v) in dic {
                res[k] = encode(object: v)

            }
        } else {
            let mirror = Mirror(reflecting: object)
            let childrens = mirror.children
            for child in childrens {
                if let key = child.label {
                    res[key] = encodeValue(value: child.value)
                }
            }
        }
        if res.count == 0 {
            return nil
        }
        return res
    }

    static private func encodeValue<T>(value: T) -> Any? {
        var obj: Any? = []
        switch value {

        case is Int,
             is UInt,
             is Double,
             is Float,
             is Bool,
             is String:
            obj = value
        case let oid as ObjectId:
            obj = oid.hexString
        case let v as Date:
            obj = v.timeIntervalSince1970.description
        case let v as [String: Any?]:
            var val: [String: Any?] = [:]
            for (k, v) in v {
                if v == nil {
                    val[k] = nil
                } else {
                    val[k] = encodeValue(value: v)
                }
            }
            obj = val
        case let v as [Any?]:
            var val: [Any?] = []
            for i in v {
                if i == nil {
                    val.append(nil)
                } else {
                    val.append(encodeValue(value: i))
                }
            }
            obj = val
        default:
            obj = encode(object: value)
        }
        return obj
    }
}

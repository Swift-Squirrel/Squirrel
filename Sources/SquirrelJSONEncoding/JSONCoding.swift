//
//  JSONCoding.swift
//  Micros
//
//  Created by Filip Klembara on 7/17/17.
//
//

import Foundation
import SquirrelConnector

public struct JSONCoding {
    private init() {
    }

    public static func encodeSerializeJSON<T>(object: T) -> Any? {
        let desc = Mirror(reflecting: object).description
        if desc.hasPrefix("Mirror for Array<") {
            var name = desc.components(separatedBy: "<")[1]
            name = name[..<name.index(before: name.endIndex)] + "s"

            let first = name.lowercased()[..<name.index(after: name.startIndex)]
            let rest = String(name.characters.dropFirst())
            name = "\(first)\(rest)"
            return encode(object: [name: object])
        }
        return encode(object: object)
    }
    public static func encodeDataJSON<T>(object: T) throws -> Data {
        if let data = encodeSerializeJSON(object: object) {
            return try dataSerialization(data: data)
        } else {
            throw JSONError(kind: .encodeError, message: "Can not encode object to JSON.")
        }
    }

    static private func dataSerialization(data: Any) throws -> Data{
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: data,
            options: []
            ) {
            return theJSONData
        } else {
            throw JSONError(kind: .parseError, message: "Can not serialize data to json format.")
        }
    }

    public static func isValid(json: String) -> Bool {
        return toJSON(json: json) != nil
    }

    public static func toJSON(json string: String) -> Any? {
        guard let data = string.data(using: .utf8, allowLossyConversion: false) else {
            return false
        }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }

    public static func encodeJSON<T>(object: T) throws -> String {
        let theJSONData = try encodeDataJSON(object: object)
        if let theJSONText = String(data: theJSONData, encoding: .utf8) {
            return theJSONText
        } else {
            throw JSONError(kind: .dataEncodingError, message: "Can not encode data")
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
            return arr.map( { encode(object: $0 ) } )
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

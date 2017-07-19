//
//  JSONCoding.swift
//  Micros
//
//  Created by Filip Klembara on 7/17/17.
//
//

import Foundation

struct JSONCoding {
    private init() {

    }

    static func encodeDataJSON<T>(object: T) throws -> Data {
        if let data = encode(object: object) {
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: data,
                options: []
                ) {
                return theJSONData
            } else {
                throw MyError.unknownError
            }
        } else {
            throw MyError.unknownError
        }
    }

    static func isValid(json: String) -> Bool {
        guard let data = json.data(using: .utf8, allowLossyConversion: false) else {
            return false
        }
        return ((try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)) != nil)
    }

    static func encodeJSON<T>(object: T) throws -> String {
        let theJSONData = try encodeDataJSON(object: object)
        if let theJSONText = String(data: theJSONData, encoding: .utf8) {
            return theJSONText
        } else {
            throw MyError.unknownError
        }
    }

    static private func encode<T>(object: T) -> Any? {
        let childrens = Mirror(reflecting: object).children
        var res: [String: Any] = [:]
        for child in childrens {
            if let key = child.label {
                res[key] = encodeValue(value: child.value)
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

        case let v as Int:
            obj = v
        case let v as UInt:
            obj = v
        case let v as Double:
            obj = v
        case let v as Float:
            obj = v
        case let v as Bool:
            obj = v
        case let v as String:
            obj = v
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

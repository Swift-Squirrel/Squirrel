/*
 * Copyright 2017 Tris Foundation and the project authors
 * Modifications copyright (C) 2017 Swift Squirrel
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License
 *
 * See https://github.com/tris-foundation/http/blob/master/LICENSE.txt in the project root for license information
 * See https://github.com/tris-foundation/http/blob/master/CONTRIBUTORS.txt for the list of the project authors
 */

public struct KeyValueDecoder {
    public init() {}

    public func decode<T: Decodable>(
        _ type: T.Type,
        from values: [String : String]
        ) throws -> T {
        let decoder = _KeyValueDecoder(values)
        return try T(from: decoder)
    }
}

fileprivate struct _KeyValueDecoder: Decoder {
    var codingPath: [CodingKey] {
        return []
    }
    var userInfo: [CodingUserInfoKey : Any] {
        return [:]
    }

    let values: [String : String]
    init(_ values: [String : String]) {
        self.values = values
    }

    func container<Key>(
        keyedBy type: Key.Type
        ) throws -> KeyedDecodingContainer<Key> {
        let container = KeyValueKeyedDecodingContainer<Key>(self)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError("unsupported container")
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return KeyValueSingleValueDecodingContainer(self)
    }
}

fileprivate struct KeyValueKeyedDecodingContainer<K : CodingKey>
: KeyedDecodingContainerProtocol {
    var codingPath: [CodingKey] {
        return []
    }
    var allKeys: [K] {
        return []
    }

    let decoder: _KeyValueDecoder

    init(_ decoder: _KeyValueDecoder) {
        self.decoder = decoder
    }

    func contains(_ key: K) -> Bool {
        return decoder.values[key.stringValue] != nil
    }

    func decodeNil(forKey key: K) throws -> Bool {
        if let _ = decoder.values[key.stringValue] {
            return false
        }
        return true
    }

    func decode(_ type: Bool.Type, forKey key: K) throws -> Bool {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = Bool(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: Int.Type, forKey key: K) throws -> Int {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = Int(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: Int8.Type, forKey key: K) throws -> Int8 {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = Int8(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: Int16.Type, forKey key: K) throws -> Int16 {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = Int16(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: Int32.Type, forKey key: K) throws -> Int32 {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = Int32(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: Int64.Type, forKey key: K) throws -> Int64 {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = Int64(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: UInt.Type, forKey key: K) throws -> UInt {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = UInt(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: UInt8.Type, forKey key: K) throws -> UInt8 {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = UInt8(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: UInt16.Type, forKey key: K) throws -> UInt16 {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = UInt16(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: UInt32.Type, forKey key: K) throws -> UInt32 {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = UInt32(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: UInt64.Type, forKey key: K) throws -> UInt64 {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = UInt64(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: Float.Type, forKey key: K) throws -> Float {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = Float(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: Double.Type, forKey key: K) throws -> Double {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        guard let result = Double(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value, for: key))
        }
        return result
    }

    func decode(_ type: String.Type, forKey key: K) throws -> String {
        guard let value = decoder.values[key.stringValue] else {
            throw DecodingError.keyNotFound(key, nil)
        }
        return value
    }

    func decode<T>(
        _ type: T.Type, forKey key: K
        ) throws -> T where T : Decodable {
        fatalError("unsupported")
    }

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type, forKey key: K
        ) throws -> KeyedDecodingContainer<NestedKey> {
        fatalError("unsupported")
    }

    func nestedUnkeyedContainer(
        forKey key: K
        ) throws -> UnkeyedDecodingContainer {
        fatalError("unsupported")
    }

    func superDecoder() throws -> Decoder {
        return decoder
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        fatalError("unsupported")
    }
}

fileprivate struct KeyValueSingleValueDecodingContainer: SingleValueDecodingContainer {
    var codingPath: [CodingKey] {
        return []
    }

    let decoder: _KeyValueDecoder
    init(_ decoder: _KeyValueDecoder) {
        self.decoder = decoder
    }

    func decodeNil() -> Bool {
        guard decoder.values.isEmpty else {
            return false
        }
        return true
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        guard let value = decoder.values["bool"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Bool(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int.Type) throws -> Int {
        guard let value = decoder.values["int"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        guard let value = decoder.values["int"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int8(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        guard let value = decoder.values["int"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int16(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        guard let value = decoder.values["int"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int32(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        guard let value = decoder.values["int"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int64(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        guard let value = decoder.values["uint"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard let value = decoder.values["uint"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt8(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard let value = decoder.values["uint"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt16(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard let value = decoder.values["uint"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt32(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard let value = decoder.values["uint"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt64(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Float.Type) throws -> Float {
        guard let value = decoder.values["float"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Float(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Double.Type) throws -> Double {
        guard let value = decoder.values["double"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Double(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: String.Type) throws -> String {
        guard let value = decoder.values["string"] else {
            throw DecodingError.valueNotFound(type, nil)
        }
        return value
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        fatalError("unsupported")
    }
}

extension DecodingError.Context {
    static func description(_ string: String) -> DecodingError.Context {
        return DecodingError.Context(codingPath: [], debugDescription: string)
    }

    static func incompatible(
        with value: String
        ) -> DecodingError.Context {
        return .description("incompatible with \(value)")
    }

    static func incompatible<T: CodingKey>(
        with value: String, for key: T
        ) -> DecodingError.Context {
        return .description("incompatible with \(value) for \(key)")
    }
}

extension DecodingError.Context: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.codingPath = []
        self.debugDescription = value
        self.underlyingError = nil
    }
}

extension DecodingError.Context: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.codingPath = []
        self.debugDescription = ""
        self.underlyingError = nil
    }
}

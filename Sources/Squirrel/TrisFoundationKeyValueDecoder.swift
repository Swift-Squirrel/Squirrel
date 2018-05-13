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
    static let universalKey = "<any>"
    public init() {}

    public func decode<T: Decodable>(
        _ type: T.Type,
        from values: [String : String]
        ) throws -> T {
        let decoder = _KeyValueDecoder(values)
        return try T(from: decoder)
    }
}

extension KeyValueDecoder {
    static func badRequest() throws -> Never {
        throw HTTPError(.badRequest, description: "Can not build required type.")
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
        let container = try KeyValueUnkeyedDecodingContainer(values: values, superDecoder: self)
        return container
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return KeyValueSingleValueDecodingContainer(self)
    }
}

fileprivate struct KeyValueUnkeyedDecodingContainer: UnkeyedDecodingContainer {
    var codingPath: [CodingKey] {
        return []
    }

    var count: Int? {
        return values.count
    }

    var isAtEnd: Bool {
        return currentIndex == values.endIndex
    }

    var currentIndex: Int

    var superDec: _KeyValueDecoder

    let values: [String]

    init(values: [String: String], superDecoder: _KeyValueDecoder) throws {
        self.superDec = superDecoder
        self.values = try values.map { (arg) -> (Int, String) in

            let (key, value) = arg
            guard let index = Int(key) else {
                let context = DecodingError.Context(codingPath: [], debugDescription: "expecting key format '[<number>]' but \(key) got")
                throw DecodingError.dataCorrupted(context)
            }
            return (index, value)
            }.sorted { $0.0 < $1.0 }.map { $0.1 }
        currentIndex = self.values.startIndex
    }

    mutating func decodeNil() throws -> Bool {
        guard ["nil", "None", "null"].contains(values[currentIndex]) else {
            return false
        }
        currentIndex += 1
        return true
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        let value = next()
        guard let obj = Bool(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: String.Type) throws -> String {
        return next()
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        let value = next()
        guard let obj = Double(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        let value = next()
        guard let obj = Float(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        let value = next()
        guard let obj = Int(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        let value = next()
        guard let obj = Int8(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        let value = next()
        guard let obj = Int16(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        let value = next()
        guard let obj = Int32(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        let value = next()
        guard let obj = Int64(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        let value = next()
        guard let obj = UInt(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {

        let value = next()
        guard let obj = UInt8(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {

        let value = next()
        guard let obj = UInt16(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        let value = next()
        guard let obj = UInt32(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        let value = next()
        guard let obj = UInt64(value) else {
            throw DecodingError.typeMismatch(
                type, .incompatible(with: value))
        }
        return obj
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try T.init(from: _KeyValueDecoder([KeyValueDecoder.universalKey: next()]))
    }

    mutating func next() -> String {
        let value = values[currentIndex]
        currentIndex += 1
        return value
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try KeyValueDecoder.badRequest()
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try KeyValueDecoder.badRequest()
    }

    mutating func superDecoder() throws -> Decoder {
        try KeyValueDecoder.badRequest()
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
        let _values = decoder.values.filter { $0.key.hasPrefix(key.stringValue) }.map { (k, v) -> (String, String) in
            var nk = k.dropFirst(key.stringValue.count).description
            if nk.count < 3 || nk.first != "[" || nk.last != "]" {
                return (key.stringValue, v)
            }

            nk.removeFirst()
            nk.removeLast()
            return (nk, v)
        }
        var values = [String: String]()
        for (k, v) in _values {
            values[k] = v
        }
        let dec = _KeyValueDecoder(values)
        return try T.init(from: dec)
    }

    func nestedContainer<NestedKey>(
        keyedBy type: NestedKey.Type, forKey key: K
        ) throws -> KeyedDecodingContainer<NestedKey> {
        try KeyValueDecoder.badRequest()
    }

    func nestedUnkeyedContainer(
        forKey key: K
        ) throws -> UnkeyedDecodingContainer {
        try KeyValueDecoder.badRequest()
    }

    func superDecoder() throws -> Decoder {
        return decoder
    }

    func superDecoder(forKey key: K) throws -> Decoder {
        try KeyValueDecoder.badRequest()
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
        guard let value = valueFor("bool") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Bool(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int.Type) throws -> Int {
        guard let value = valueFor("int") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        guard let value = valueFor("int") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int8(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        guard let value = valueFor("int") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int16(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        guard let value = valueFor("int") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int32(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        guard let value = valueFor("int") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Int64(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        guard let value = valueFor("uint") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        guard let value = valueFor("uint") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt8(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        guard let value = valueFor("uint") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt16(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        guard let value = valueFor("uint") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt32(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        guard let value = valueFor("uint") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = UInt64(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Float.Type) throws -> Float {
        guard let value = valueFor("float") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Float(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: Double.Type) throws -> Double {
        guard let value = valueFor("double") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        guard let result = Double(value) else {
            throw DecodingError.typeMismatch(type, .incompatible(with: value))
        }
        return result
    }

    func decode(_ type: String.Type) throws -> String {
        guard let value = valueFor("string") else {
            throw DecodingError.valueNotFound(type, nil)
        }
        return value
    }

    private func valueFor(_ key: String) -> String? {
        return decoder.values[key] ?? decoder.values[KeyValueDecoder.universalKey]
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try T.init(from: decoder)
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
        self.init(codingPath: [], debugDescription: value, underlyingError: nil)
    }
}

extension DecodingError.Context: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(codingPath: [], debugDescription: "", underlyingError: nil)
    }
}

//
//  JSON.swift
//  SquirrelJSONEncoding
//
//  Created by Filip Klembara on 9/3/17.
//

public struct JSON {

    private let data: Any?

    public init(string: String) throws {
        guard let data = JSONCoding.toJSON(json: string) else {
            throw JSONError(kind: .parseError, message: "Corrupted content")
        }
        self.data = data
    }

    public init(from data: Any?) {
        self.data = data
    }




}

public extension JSON {
    public var string: String? {
        guard let data = self.data else {
            return nil
        }
        guard let str = data as? String else {
            return nil
        }
        return str
    }

    public var stringValue: String {
        return string ?? ""
    }
}

extension JSON {
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

    public var dictionaryValue: [String: JSON] {
        return dictionary ?? [:]
    }

    public subscript(key: String) -> JSON {
        if let dic = dictionary, let value = dic[key] {
            return value
        }
        return JSON(from: nil)
    }
}

public extension JSON {
    public var array: [JSON]? {
        guard let data = self.data else {
            return nil
        }

        guard let arr = data as? [Any] else {
            return nil
        }

        return arr.map({ JSON(from: $0) })
    }

    public var arrayValue: [JSON] {
        return array ?? []
    }
}

extension JSON {
    public var int: Int? {
        guard let data = self.data else {
            return nil
        }

        return data as? Int
    }

    public var intValue: Int {
        return int ?? 0
    }
}

extension JSON {
    var isNil: Bool {
        return data == nil
    }

    var isEmpty: Bool {
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

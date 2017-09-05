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
    public var double: Double? {
        guard let data = self.data else {
            return nil
        }

        return data as? Double
    }

    public var doubleValue: Double {
        return double ?? 0.0
    }
}

extension JSON {
    public var bool: Bool? {
        guard let data = self.data else {
            return nil
        }

        return data as? Bool
    }

    public var boolValue: Bool {
        return bool ?? false
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

extension JSON: Equatable {
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
        case let bool as Bool:
            return bool == rdata as? Bool
        case let int as Int:
            return int == rdata as? Int
        case let double as Double:
            return double == rdata as? Double
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
}

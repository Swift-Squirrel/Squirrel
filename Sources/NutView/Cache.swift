//
//  Cache.swift
//  NutView
//
//  Created by Filip Klembara on 9/10/17.
//

import Cache
import SquirrelJSONEncoding
import Foundation

extension ViewToken: Cachable {
    static func decode(_ data: Data) -> ViewToken? {
        guard let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        let parser = FruitParser(content: string)
        return parser.tokenize()
    }

    func encode() -> Data? {
        var res = [String: Any]()
        res["body"] = body.map({ $0.serialized })
        if head.count > 0 {
            res["head"] = head.map({ $0.serialized })
        }
        if let layout = self.layout {
            res["layout"] = layout
        }
        res["fileName"] = name
        let data: Data? = try? JSONCoding.encodeDataJSON(object: res)
        return data
    }

    typealias CacheType = ViewToken
}

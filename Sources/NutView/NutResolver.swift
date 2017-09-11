//
//  NutResolver.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/11/17.
//
//

import Foundation
import PathKit
import Cache

protocol NutResolverProtocol {
    static func viewToken(for name: String) throws -> ViewToken
}

struct NutResolver: NutResolverProtocol {
    private static var cache: SpecializedCache<ViewToken> {
        return NutConfig.NutViewCache.cache
    }
    static func viewToken(for name: String) throws -> ViewToken {
        let nutName = name.replacingAll(matching: "\\.", with: "/") + ".nut"
        let fruitName = name + ".fruit"

        let fruit = NutConfig.fruits + fruitName
        let nut = NutConfig.nuts + nutName
        let fruitValid = isValid(fruit: fruit, nut: nut)
        if let token = cache["name"], fruitValid {
            return token
        }

        guard nut.exists else {
            throw NutError(kind: .notExists(name: nutName))
        }

        let vToken: ViewToken

        if fruit.exists && fruitValid {
            let content: String = try fruit.read()
            let parser = FruitParser(content: content)
            vToken = parser.tokenize()
        } else {
            let content: String = try nut.read()
            let parser = NutParser(content: content, name: nutName)
            vToken = try parser.tokenize()

            let serialized = parser.jsonSerialized
            if fruit.exists {
                if let cnt: String = try? fruit.read() {
                    guard cnt != serialized else {
                        return vToken
                    }
                }
            }
            try? fruit.write(serialized)
        }
        try? cache.addObject(vToken, forKey: name)
        return vToken
    }

    private static func isValid(fruit: Path, nut: Path) -> Bool {
        guard let fruitModif = getModificationDate(for: fruit) else {
            return false
        }

        guard let nutModif = getModificationDate(for: nut) else {
            return false
        }

        return fruitModif > nutModif
    }

    private static func getModificationDate(for path: Path) -> Date? {
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: path.string) else {
            return nil
        }
        return attributes[FileAttributeKey.modificationDate] as? Date
    }

}

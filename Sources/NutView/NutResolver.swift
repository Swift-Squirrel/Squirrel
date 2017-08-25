//
//  NutResolver.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/11/17.
//
//

import Foundation
import SquirrelConfig
import PathKit

protocol NutResolverProtocol {
    func viewToken(for name: String) throws -> ViewToken
}

class NutResolver: NutResolverProtocol {

    private init() { }

    static let sharedInstance = NutResolver()

    private var parsedNuts: [String: FruitInfo] = [:]

    private struct FruitInfo {
        let viewToken: ViewToken
        let name: String

        let fruit: Path
        let nut: Path

        init(name: String, viewToken: ViewToken, fruit: Path, nut: Path) {
            self.name = name
            self.viewToken = viewToken
            self.fruit = fruit
            self.nut = nut
        }

        var valid: Bool {
            guard let fruitModif = getModificationDate(for: fruit) else {
                return false
            }

            guard let nutModif = getModificationDate(for: nut) else {
                return false
            }

            return fruitModif > nutModif
        }

        private func getModificationDate(for path: Path) -> Date? {
            return (try? FileManager.default.attributesOfItem(atPath: path.string))?[FileAttributeKey.modificationDate] as? Date
        }
    }

    private func getModificationDate(for path: Path) -> Date? {
        return (try? FileManager.default.attributesOfItem(atPath: path.string))?[FileAttributeKey.modificationDate] as? Date
    }

    func viewToken(for name: String) throws -> ViewToken {
        if let fruitInfo = parsedNuts[name], fruitInfo.valid {
            return fruitInfo.viewToken
        }

        let nutName = name.components(separatedBy: ".").joined(separator: "/") + ".nut"
        let fruitName = name + ".fruit"

        let fruit = Config.sharedInstance.storageViews + fruitName
        let nut = Config.sharedInstance.views + nutName

        guard nut.exists else {
            throw NutError(kind: .notExists(name: nutName))
        }

        let vToken: ViewToken

        if fruit.exists,
            let nutModif = getModificationDate(for: nut),
            let fruitModif = getModificationDate(for: fruit),
            fruitModif > nutModif
        {
            let content: String = try fruit.read()
            let parser = FruitParser(content: content)
            vToken = parser.tokenize()
        } else {
            let content: String = try nut.read()
            let parser = NutParser(content: content, name: nutName)
            vToken = try parser.tokenize()

            // TODO separated thread
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


        parsedNuts[name] = FruitInfo(name: name, viewToken: vToken, fruit: fruit, nut: nut)
//        try vToken.subviews.forEach { (subview) throws -> Void in
//            if parsedNuts[subview.name] == nil {
//                let _ = try viewToken(for: subview.name)
//            }
//        }
//        if let layoutName = vToken.layout?.name, parsedNuts[layoutName] == nil {
//            let _ = try viewToken(for: layoutName)
//        }
        return vToken
    }
}

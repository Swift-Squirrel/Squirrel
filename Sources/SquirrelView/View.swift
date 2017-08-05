//
//  View.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

import PathKit
import SquirrelConfig
import Foundation
import SquirrelJSONEncoding

public struct View: ViewProtocol {
    public func getContent() throws -> String {
        guard sourceExists else {
            throw ViewError(kind: .notExists, description: "Source file \(name).nut does not exists")
        }
        if compiledExists {
            guard let nutModif = getModificationDate(path: path) else {
                throw ViewError(kind: .getModif, description: "Can not get modif date for \(name).nut")
            }

            guard let fruitModif = getModificationDate(path: compiledPath) else {
                throw ViewError(kind: .getModif, description: "Can not get modif date for \(name).fruit")
            }

            if fruitModif > nutModif {
                return try run()
            }
        }

        compile()
        
        return try run()
    }

    private let path: Path
    private let compiledPath: Path

    private let name: String

    public var sourceExists: Bool {
        return path.exists
    }

    private var compiledExists: Bool {
        return compiledPath.exists
    }

    private func getModificationDate(path: Path) -> Date? {
        return (try? FileManager.default.attributesOfItem(atPath: path.string))?[FileAttributeKey.modificationDate] as? Date
    }

    private func compile() {
        let cont: String = (try? path.read()) ?? "err"
        try? compiledPath.write("Compiled " + cont)
    }

    private func run() throws -> String {
        let content: String = try! compiledPath.read()
        let viewParser = ViewParser(text: content)
        let res = try viewParser.parse()

        return res
    }

    public init(name: String) {
        self.name = name
//        self.data = nil
        path = Path(components: [Config.sharedInstance.views.string, name + ".nut"]).normalize()
        compiledPath = Path(components: [Config.sharedInstance.storageViews.string, name + ".fruit"]).normalize()
    }

    public init<T>(name: String, object: T) throws {
        self.init(name: name)
        guard let data = JSONCoding.encode(object: object) as? [String: Any] else {
            throw JSONError(kind: .encodeError, message: "Encode error")
        }
        ViewParser.data = data
    }
}

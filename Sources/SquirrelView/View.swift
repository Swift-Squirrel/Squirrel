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
import NutView

public struct View: ViewProtocol {
    public func getContent() throws -> String {
        guard sourceExists else {
            throw ViewError(kind: .notExists, description: "Source file \(name).nut does not exists")
        }
        if compiledExists {
            guard let nutModif = getModificationDate(path: nut) else {
                throw ViewError(kind: .getModif, description: "Can not get modif date for \(name).nut")
            }

            guard let fruitModif = getModificationDate(path: fruit) else {
                throw ViewError(kind: .getModif, description: "Can not get modif date for \(name).fruit")
            }

            if fruitModif > nutModif {
                return try run()
            }
        }

        try compile()
        
        return try run()
    }

    private let nut: Path
    private let fruit: Path
    private let resources: Path
    private let storage: Path
    private let interpreter: NutInterpreterProtocol

    private let name: String

    public var sourceExists: Bool {
        return nut.exists
    }

    private var compiledExists: Bool {
        return fruit.exists
    }

    private func getModificationDate(path: Path) -> Date? {
        return (try? FileManager.default.attributesOfItem(atPath: path.string))?[FileAttributeKey.modificationDate] as? Date
    }

    private func compile() throws {
        let cont: String = try nut.read()
        interpreter.setContent(content: cont)
        try! interpreter.tokenize()
//        try? compiledPath.write("Compiled " + cont)
    }

    private func run() throws -> String {
//        let content: String = try! compiledPath.read()
//        let viewParser = ViewParser(text: content)
//        let res = try viewParser.parse()

//        return res
        return ""
    }

    public init(name: String) {
        self.name = name
//        self.data = nil
        nut = Path(components: [Config.sharedInstance.views.string, name + ".nut"]).normalize()
        resources = nut.parent()
        fruit = Path(components: [Config.sharedInstance.storageViews.string, name + ".fruit"]).normalize()
        storage = fruit.parent()
        interpreter = NutInterpreter(resources: resources, storage: storage)
    }

    public init<T>(name: String, object: T) throws {
        self.init(name: name)
        guard let data = JSONCoding.encode(object: object) as? [String: Any] else {
            throw JSONError(kind: .encodeError, message: "Encode error")
        }
//        ViewParser.data = data
    }
}

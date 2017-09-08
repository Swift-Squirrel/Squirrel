//
//  View.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

import SquirrelJSONEncoding

public struct View: ViewProtocol {

    private let name: String
    private let data: [String: Any]
    private let interpreter: NutInterpreterProtocol

    public init(name: String) {
        self.name = name
        self.data = [:]
        self.interpreter = NutInterpreter(view: name, with: data)
    }

    public init<T>(name: String, with object: T?) throws {
        self.name = name
        if let object = object {
            guard let data = JSONCoding.encodeSerializeJSON(object: object) as? [String: Any] else {
                throw JSONError(kind: .encodeError, message: "Encode error")
            }
            self.data = data
        } else {
            self.data = [:]
        }
        interpreter = NutInterpreter(view: name, with: data)
    }

    public func getContent() throws -> String {
        return try interpreter.resolve()
    }
}

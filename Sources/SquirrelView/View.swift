//
//  View.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

import SquirrelJSONEncoding
import NutView

public struct View: ViewProtocol {

    private let name: String
    private let data: [String: Any]
    private let interpreter: NutInterpreterProtocol

    public init<T>(name: String, object: T? = nil) throws {
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

    public mutating func getContent() throws -> String {
        return try interpreter.resolve()
    }
}

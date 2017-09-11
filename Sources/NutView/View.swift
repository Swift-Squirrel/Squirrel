//
//  View.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

import SquirrelJSONEncoding

/// Represents html document generated from *.nut* file
public struct View: ViewProtocol {

    private let name: String
    private let data: [String: Any]
    private let interpreter: NutInterpreterProtocol

    /// Construct from name of view
    ///
    /// - Note: For name use dot convention. Instead of "Page/View.nut" use "Page.View"
    ///
    /// - Parameter name: Name of View file without extension (*.nut*)
    public init(name: String) {
        self.name = name
        self.data = [:]
        self.interpreter = NutInterpreter(view: name, with: data)
    }

    /// Construct from name of view
    ///
    /// - Note: For name use dot convention. Instead of "Page/View.nut" use "Page.View"
    ///
    /// - Parameter name: Name of View file without extension (*.nut*)
    /// - Parameter with: Struct or Class with data which will fill the view
    public init<T>(name: String, with object: T?) throws {
        self.name = name
        if let object = object {
            guard let data = JSONCoding.encodeSerializeJSON(object: object) as? [String: Any] else {
                throw JSONError(kind: .encodeError, description: "Encode error")
            }
            self.data = data
        } else {
            self.data = [:]
        }
        interpreter = NutInterpreter(view: name, with: data)
    }

    /// Resolve View and return its content
    ///
    /// - Returns: Content of resolved *.nut* view and all of ith subviews
    /// - Throws: `NutParserError`
    public func getContent() throws -> String {
        return try interpreter.resolve()
    }
}

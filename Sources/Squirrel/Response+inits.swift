//
//  Response+inits.swift
//  Micros
//
//  Created by Filip Klembara on 7/15/17.
//
//

import Foundation
import PathKit
import NutView
import SquirrelJSONEncoding

// MARK: - JSON and HTML
public extension Response {
    /// Constructs html response from file
    ///
    /// - Parameter path: path to file
    /// - Throws: Filesystem errors
    public convenience init(html path: Path) throws {
        try self.init(pathToFile: path)
        setHeader(
            for: HTTPHeaders.ContentType.contentType,
            to: HTTPHeaders.ContentType.Text.html.rawValue)
    }

    /// Construct html response from given string
    ///
    /// - Parameter html: html response
    /// - Throws: `DataError(kind: dataCodingError(string:)`
    public convenience init(status: HTTPStatus = .ok, html: String) throws {
        guard let data = html.data(using: .utf8) else {
            throw DataError(kind: .dataCodingError(string: html))
        }
        self.init(
            status: status,
            headers: [
                HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue
            ],
            body: data
        )
    }

    /// Constructs JSON response from given object
    ///
    /// - Parameter json: Object to serialize
    /// - Throws: `JSONError` and swift JSON errors
    public convenience init<T>(object: T) throws {
        let data = try JSONCoding.encodeDataJSON(object: object)
        self.init(
            headers: [
                HTTPHeaders.ContentType.contentType:
                    HTTPHeaders.ContentType.Application.json.rawValue
            ],
            body: data
        )
    }

    /// Constructs JSON response from given string
    ///
    /// - Parameter json: JSON string representation
    /// - Throws: `DataError(kind: .dataCodingError(string:))` if string is not in utf8
    ///   and `JSONError(kind: .parseError, description:)` if given string is not valid JSON
    public convenience init(json: String) throws {
        guard let data = json.data(using: .utf8) else {
            throw DataError(kind: .dataCodingError(string: json))
        }

        guard JSONCoding.isValid(json: json) else {
            throw JSONError(kind: .parseError, description: "'\(json)' is not valid json format")
        }

        self.init(
            headers: [
                HTTPHeaders.ContentType.contentType:
                    HTTPHeaders.ContentType.Application.json.rawValue
            ],
            body: data
        )
    }
}

// MARK: - Construct view
extension Response {
    /// Construct response from given view
    ///
    /// - Parameters:
    ///   - status: HTTP status
    ///   - view: View
    /// - Throws: View error or Data coding error
    public convenience init(status: HTTPStatus = .ok, view: ViewProtocol) throws {
        let content = try view.getContent()
        try self.init(status: status, html: content)
    }
}

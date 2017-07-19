//
//  Response+inits.swift
//  Micros
//
//  Created by Filip Klembara on 7/15/17.
//
//

import Foundation
import PathKit

// JSON and HTML
extension Response {
    convenience init(html path: Path) throws {
        try self.init(pathToFile: path)
        setHeader(for: HTTPHeaders.ContentType.contentType, to: HTTPHeaders.ContentType.Text.html.rawValue)
    }

    convenience init(html: String) throws {
        guard let data = html.data(using: .utf8) else {
            throw MyError.unknownError
        }
        self.init(
            headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
            body: data
        )
    }

    convenience init<T>(object: T) throws {
        let data = try JSONCoding.encodeDataJSON(object: object)
        self.init(
            headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Application.json.rawValue],
            body: data
        )
    }

    convenience init(json: String) throws {
        guard let data = json.data(using: .utf8) else {
            throw MyError.unknownError
        }

        guard JSONCoding.isValid(json: json) else {
            throw MyError.unknownError
        }

        self.init(
            headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Application.json.rawValue],
            body: data
        )
    }
}

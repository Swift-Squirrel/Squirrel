//
//  Response+inits.swift
//  Micros
//
//  Created by Filip Klembara on 7/15/17.
//
//

import Foundation
import PathKit
import SquirrelJSON
import SquirrelCore

// MARK: - JSON and HTML
public extension Response {
    /// Constructs html response from file
    ///
    /// - Parameter path: path to file
    /// - Throws: Filesystem errors
    public convenience init(html path: Path) throws {
        try self.init(pathToFile: path)
        setHeader(to: .contentType(.html))
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
            headers: [.contentType(.html)],
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
            headers: [.contentType(.json)],
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
            headers: [.contentType(.json)],
            body: data
        )
    }
}

// MARK: - Construct presentable
extension Response {
    /// Construct response from given presentable object
    ///
    /// - Parameters:
    ///   - status: HTTP status
    ///   - presentable: object to present
    /// - Throws: Custom object presentation errors
    public convenience init(status: HTTPStatus = .ok,
                            presentable object: SquirrelPresentable) throws {
        let data = try object.present()
        switch object.representAs {
        case .html:
            self.init(
                status: status,
                headers: [.contentType(.html)],
                body: data)
        case .json:
            self.init(
                status: status,
                headers: [.contentType(.json)],
                body: data)
        case .text:
            self.init(status: status, body: data)
        }
    }
}

// MARK: - Download
public extension Response {
    /// Response which force download
    ///
    /// - Parameter file: Path to file
    /// - Throws: file read Errors
    convenience init (download file: Path) throws {
        let fileName = file.lastComponent
        try self.init(pathToFile: file)
        setDownloadHeaders(fileName: fileName)
    }

    /// Response which force download
    ///
    /// - Parameters:
    ///   - data: Data to download
    ///   - name: Name
    convenience init(download data: Data, name: String) {
        self.init(body: data)
        setDownloadHeaders(fileName: name)
    }

    private func setDownloadHeaders(fileName: String) {
        setHeader(for: "Content-Disposition", to: "attachment; filename=\"\(fileName)\"")
        setHeader(to: .contentType(.forceDownload))
        setHeader(for: "Content-Transfer-Encoding", to: "binary")
    }
}

//
//  Multipart.swift
//  Squirrel
//
//  Created by Filip Klembara on 10/24/17.
//

import Foundation

/// post multipart body
public struct Multipart {
    /// Name
    public let name: String
    /// Filename
    public let fileName: String?
    /// Content
    private let content: Data

    init(name: String, fileName: String?, content: Data) {
        self.name = name
        self.fileName = fileName
        self.content = content
    }

    /// Check if content is file
    public var isFile: Bool {
        return fileName != nil
    }

    /// Returns data
    public var fileContent: Data {
        return content
    }

    /// Returns data as String
    public var stringContent: String? {
        return String(data: content, encoding: .utf8)
    }
}

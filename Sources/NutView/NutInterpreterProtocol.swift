//
//  NutInterpreterProtocol.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/6/17.
//
//

import Foundation
import PathKit

public protocol NutInterpreterProtocol {

    init(resources: Path, storage: Path)

    func tokenize() throws -> String

    func setContent(content: String)
}

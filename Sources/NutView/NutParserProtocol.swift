//
//  NutParserProtocol.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/6/17.
//
//

protocol NutParserProtocol {

    init(content: String)

    func tokenize() throws -> ViewToken

    var jsonSerialized: String { get }
}

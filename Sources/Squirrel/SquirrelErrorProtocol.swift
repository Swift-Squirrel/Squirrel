//
//  File.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

protocol SquirrelErrorProtocol: Error, CustomStringConvertible, AsHTTPProtocol {

}

public protocol AsHTTPProtocol {
    var asHTTPError: HTTPError { get }
}

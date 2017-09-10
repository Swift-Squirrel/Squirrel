//
//  SquirrelErrorProtocol.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

/// Protocol used for most of SquirrelErrors
public protocol SquirrelErrorProtocol: Error, CustomStringConvertible, AsHTTPProtocol {

}

/// Bridge between Error and HTTPErrors
public protocol AsHTTPProtocol {
    var asHTTPError: HTTPError { get }
}

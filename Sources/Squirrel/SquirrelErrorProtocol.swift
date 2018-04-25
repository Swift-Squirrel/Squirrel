//
//  SquirrelErrorProtocol.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/4/17.
//
//

import SquirrelCore

/// Bridge between Error and HTTPErrors
public protocol HTTPConvertibleError: SquirrelError {
    var asHTTPError: HTTPError { get }
}

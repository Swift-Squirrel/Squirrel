//
//  Router.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/13/17.
//

import Foundation

/// Router
public protocol Router: RouteGroup { }

struct CommonRouter: Router {
    var url: String

    var middlewareGroup: [Middleware]

    init(_ url: String, middlewares: [Middleware]) {
        middlewareGroup = middlewares
        self.url = url
    }
}

/// Route descriptor
public struct RouteDescriptor {
    /// Route url
    public let route: String
    /// Used methods
    public let methods: [RequestLine.Method]
}

// MARK: - Router + routes
public extension Router {
    /// Returns all routes
    public var routes: [RouteDescriptor] {
        return ResponseManager.sharedInstance.allRoutes
    }
}

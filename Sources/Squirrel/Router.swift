//
//  Router.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/13/17.
//

import Foundation

/// Router
public protocol Router: MiddlewareGroup {

}

struct CommonRouter: Router {
    var middlewareGroup: [Middleware]

    init(middlewares: [Middleware]) {
        middlewareGroup = middlewares
    }
}


// MARK: - routes
extension Router {
    var responseManager: ResponseManager {
        return ResponseManager.sharedInstance
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route(
        get url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request) throws -> Any) {

        responseManager.route(
            get: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route(
        get url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        responseManager.route(
            get: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route<T>(
        get url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request, T) throws -> Any) where T: Decodable {

        responseManager.route(
            get: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route<T>(
        get url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        responseManager.route(
            get: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route(
        post url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request) throws -> Any) {

        responseManager.route(
            post: url,
            middlewares: middlewareGroup + middlewares, handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route(
        post url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        responseManager.route(
            post: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route<T>(
        post url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request, T) throws -> Any) where T: Decodable {

        responseManager.route(
            post: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route<T>(
        post url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        responseManager.route(
            post: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route(
        put url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request) throws -> Any) {

        responseManager.route(
            put: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route(
        put url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        responseManager.route(
            put: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route<T>(
        put url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request, T) throws -> Any) where T: Decodable {

        responseManager.route(
            put: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route<T>(
        put url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        responseManager.route(
            put: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route(
        delete url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request) throws -> Any) {

        responseManager.route(
            delete: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route(
        delete url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        responseManager.route(
            delete: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route<T>(
        delete url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request, T) throws -> Any) where T: Decodable {

        responseManager.route(
            delete: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func route<T>(
        delete url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        responseManager.route(
            delete: url,
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }
}

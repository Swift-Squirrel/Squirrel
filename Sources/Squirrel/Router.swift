//
//  Router.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/13/17.
//

import Foundation

/// Router
public protocol Router: RouteGroup {

}

struct CommonRouter: Router {
    var url: String

    var middlewareGroup: [Middleware]

    init(_ url: String, middlewares: [Middleware]) {
        middlewareGroup = middlewares
        self.url = url
    }
}

public struct RouteDescriptor {
    let route: String
    let methods: [RequestLine.Method]
}

// MARK: - routes
extension Router {
    var responseManager: ResponseManager {
        return ResponseManager.sharedInstance
    }

    public var routes: [RouteDescriptor] {
        return responseManager.allRoutes
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func get(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request) throws -> Any) {

        responseManager.route(
            get: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func get(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        responseManager.route(
            get: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func get<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request, T) throws -> Any) where T: Decodable {

        responseManager.route(
            get: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func get<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        responseManager.route(
            get: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func post(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request) throws -> Any) {

        responseManager.route(
            post: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares, handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func post(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        responseManager.route(
            post: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func post<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request, T) throws -> Any) where T: Decodable {

        responseManager.route(
            post: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func post<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        responseManager.route(
            post: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func put(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request) throws -> Any) {

        responseManager.route(
            put: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func put(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        responseManager.route(
            put: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func put<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request, T) throws -> Any) where T: Decodable {

        responseManager.route(
            put: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func put<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        responseManager.route(
            put: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func delete(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request) throws -> Any) {

        responseManager.route(
            delete: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func delete(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        responseManager.route(
            delete: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func delete<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request, T) throws -> Any) where T: Decodable {

        responseManager.route(
            delete: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func delete<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        responseManager.route(
            delete: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func patch(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request) throws -> Any) {

        responseManager.route(
            patch: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func patch(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        responseManager.route(
            patch: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func patch<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (Request, T) throws -> Any) where T: Decodable {

        responseManager.route(
            patch: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func patch<T>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        responseManager.route(
            patch: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares,
            handler: handler)
    }
}

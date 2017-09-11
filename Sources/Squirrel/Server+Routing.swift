//
//  Server+Routing.swift
//  Micros
//
//  Created by Filip Klembara on 7/9/17.
//
//

import Foundation

// MARK: - routes
extension Server {
    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route(get url: String, handler: @escaping (Request) throws -> Any) {
        responseManager.route(get: url, handler: handler)
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route(get url: String, handler: @escaping () throws -> Any) {
        responseManager.route(get: url, handler: handler)
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route<T>(get url: String, handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

            responseManager.route(get: url, handler: handler)
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route<T>(get url: String, handler: @escaping (T) throws -> Any) where T: Decodable {
        responseManager.route(get: url, handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route(post url: String, handler: @escaping (Request) throws -> Any) {
        responseManager.route(post: url, handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route(post url: String, handler: @escaping () throws -> Any) {
        responseManager.route(post: url, handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route<T>(post url: String, handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

            responseManager.route(post: url, handler: handler)
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route<T>(post url: String, handler: @escaping (T) throws -> Any)
        where T: Decodable {
            responseManager.route(post: url, handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route(put url: String, handler: @escaping (Request) throws -> Any) {
        responseManager.route(put: url, handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route(put url: String, handler: @escaping () throws -> Any) {
        responseManager.route(put: url, handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route<T>(put url: String, handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

            responseManager.route(put: url, handler: handler)
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route<T>(put url: String, handler: @escaping (T) throws -> Any) where T: Decodable {
        responseManager.route(put: url, handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route(delete url: String, handler: @escaping (Request) throws -> Any) {
        responseManager.route(delete: url, handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route(delete url: String, handler: @escaping () throws -> Any) {
        responseManager.route(delete: url, handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route<T>(delete url: String, handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

            responseManager.route(delete: url, handler: handler)
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - handler: Response handler
    public func route<T>(delete url: String, handler: @escaping (T) throws -> Any)
        where T: Decodable {
            responseManager.route(delete: url, handler: handler)
    }
}

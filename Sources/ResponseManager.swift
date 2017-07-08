//
//  ResponseManager.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation

class ResponseManager {
    
    static let sharedInstance = ResponseManager()
    
    var routeTree = RouteTree()
    
    private init() {
    }
    
    /// routing
    ///
    /// - Parameters:
    ///   - url: url
    ///   - handler: handler
    public func route(get url: String, handler: @escaping (Request) -> Response) {
        routeTree.add(route: url, forMethod: .get, handler: handler)
    }
    
    public func route(get url: String, handler: @escaping () -> Response) {
        routeTree.add(route: url, forMethod: .get) {
            _ in handler()
        }
    }
    
    public func route(post url: String, handler: @escaping (Request) -> Response) {
        routeTree.add(route: url, forMethod: .post, handler: handler)
    }
    
    public func route(post url: String, handler: @escaping () -> Response) {
        routeTree.add(route: url, forMethod: .post) {
            _ in handler()
        }
    }
    
    func findHandler(for request: Request) -> ResponseHandler? {
        return routeTree.findHandler(for: request.method, in: request.path)
    }
}

//
//  ResponseManager.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation
import Reflection

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

    public func route<T>(get url: String, handler: @escaping (Request, T) -> Response) {
        let closure = {
            (req: Request) in
            let blueprint = Blueprint(of: T.self)
            let values = req.getURLParameters()
            let converted = blueprint.construct(using: values)! // TODO optional

            return handler(req, converted)
            } as ResponseHandler
        route(get: url, handler: closure)
    }

    public func route<T>(get url: String, handler: @escaping (T) -> Response) {
        let closure = {
            (req: Request) in
            let blueprint = Blueprint(of: T.self)
            let values = req.getURLParameters()
            let converted = blueprint.construct(using: values)! // TODO optional

            return handler(converted)
            } as ResponseHandler
        route(get: url, handler: closure)
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

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

    public func route(get url: String, handler: @escaping (Request) throws -> Any) {
        route(method: .get, url: url, handler: handler)
    }

    public func route(get url: String, handler: @escaping () throws -> Any) {
        route(get: url) { (_ :Request) in
            return try handler()
        }
    }

    public func route<T>(get url: String, handler: @escaping (Request, T) throws -> Any) {
        let closure: AnyResponseHandler = {
            [unowned self] (req: Request) in
            let converted = try self.convertParameters(request: req, object: T.self)
            return try handler(req, converted)
        }
        route(get: url, handler: closure)
    }

    public func route<T>(get url: String, handler: @escaping (T) throws -> Any) {
        let closure: AnyResponseHandler = {
            [unowned self] (req: Request) in
            let converted = try self.convertParameters(request: req, object: T.self)
            return try handler(converted)
        }
        route(get: url, handler: closure)
    }

    // POST
    public func route(post url: String, handler: @escaping (Request) throws -> Any) {
        route(method: .post, url: url, handler: handler)
    }

    public func route<T>(post url: String, handler: @escaping (T) throws -> Any) {
        let closure: AnyResponseHandler = {
            [unowned self] (req: Request) in
            let converted = try self.convertParameters(request: req, object: T.self)
            return try handler(converted)
        }
        route(post: url, handler: closure)
    }


    // CONVERTIONS
    private func convertParameters<T>(request: Request, object: T.Type) throws -> T {
        let blueprint = Blueprint(of: T.self)
        var values = request.getURLParameters()
        for (k, v) in request.postParameters {
            if(values[k] == nil) {
                values[k] = v
            }
        }
        for (k,v) in request.getParameters {
            if(values[k] == nil) {
                values[k] = v
            }
        }
        guard let converted = blueprint.construct(using: values) else {
            throw HTTPError(status: .badRequest, description: "Wrong parameters type or missing parameters")
        }
        return converted
    }


    private func route(method: HTTPHeaders.Method, url: String, handler: @escaping AnyResponseHandler) {
        routeTree.add(route: url, forMethod: method, handler: handler)
    }

    func findHandler(for request: Request) throws -> AnyResponseHandler? {
        return try routeTree.findHandler(for: request.method, in: request.path)
    }
}

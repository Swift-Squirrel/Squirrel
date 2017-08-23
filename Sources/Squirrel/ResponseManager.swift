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

    private var routeTree = RouteTree()

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

    public func route<T>(get url: String, handler: @escaping (Request, T) throws -> Any) where T: Decodable {
        let closure: AnyResponseHandler = {
            [unowned self] (req: Request) in
            let converted = try self.convertParameters(request: req, object: T.self)
            return try handler(req, converted)
        }
        route(get: url, handler: closure)
    }

    public func route<T>(get url: String, handler: @escaping (T) throws -> Any) where T: Decodable {
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

    public func route<T>(post url: String, handler: @escaping (T) throws -> Any) where T: Decodable {
        let closure: AnyResponseHandler = {
            [unowned self] (req: Request) in
            let converted = try self.convertParameters(request: req, object: T.self)
            return try handler(converted)
        }
        route(post: url, handler: closure)
    }


    // CONVERTIONS
    private func convertParameters<T>(request: Request, object: T.Type) throws -> T where T: Decodable {
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
        do {
            let jsonDecoder = JSONDecoder()
            let jsonData = try JSONSerialization.data(withJSONObject: values)
            return try jsonDecoder.decode(object, from: jsonData)
        } catch {
            throw HTTPError(status: .badRequest, description: "Wrong parameters type or missing parameters")
        }
    }


    private func route(method: HTTPHeaders.Method, url: String, handler: @escaping AnyResponseHandler) {
        routeTree.add(route: url, forMethod: method, handler: handler)
    }

    func findHandler(for request: Request) throws -> AnyResponseHandler? {
        return try routeTree.findHandler(for: request.method, in: request.path)
    }
}

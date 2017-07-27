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
            (req: Request) in
            let blueprint = Blueprint(of: T.self)
            let values = req.getURLParameters()
            guard let converted = blueprint.construct(using: values) else {
                throw HTTPError(status: .badRequest, description: "Wrong parameters type or missing parameters")
            }
            return try handler(req, converted)
        }
        route(get: url, handler: closure)
    }

    public func route<T>(get url: String, handler: @escaping (T) throws -> Any) {
        let closure: AnyResponseHandler = {
            (req: Request) in
            let blueprint = Blueprint(of: T.self)
            let values = req.getURLParameters()
            guard let converted = blueprint.construct(using: values) else {
                throw HTTPError(status: .badRequest, description: "Wrong parameters type or missing parameters")
            }
            return try handler(converted)
        }
        route(get: url, handler: closure)
    }


    private func route(method: HTTPHeaders.Method, url: String, handler: @escaping AnyResponseHandler) {
        routeTree.add(route: url, forMethod: method, handler: handler)
    }

    func findHandler(for request: Request) throws -> AnyResponseHandler? {
        return try routeTree.findHandler(for: request.method, in: request.path)
    }
}

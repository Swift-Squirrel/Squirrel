//
//  Server+Routing.swift
//  Micros
//
//  Created by Filip Klembara on 7/9/17.
//
//

import Foundation
import Reflection

extension Server {

    public func route(get url: String, handler: @escaping (Request) throws -> Any) {
        responseManager.route(method: .get, url: url, handler: handler)
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
}

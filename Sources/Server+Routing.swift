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
    
    public func route(get url: String, handler: @escaping (Request) -> Response) {
        responsManager.route(method: .get, url: url, handler: handler)
    }
    
    public func route(get url: String, handler: @escaping () -> Response) {
//        routeTree.add(route: url, forMethod: .get) {
//            _ in handler()
//        }
        route(get: url) { (_ :Request) in
            return handler()
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

}

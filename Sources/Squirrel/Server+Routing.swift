//
//  Server+Routing.swift
//  Micros
//
//  Created by Filip Klembara on 7/9/17.
//
//

import Foundation

extension Server {
    public func route(get url: String, handler: @escaping (Request) throws -> Any) {
        responseManager.route(get: url, handler: handler)
    }

    public func route(get url: String, handler: @escaping () throws -> Any) {
        responseManager.route(get: url, handler: handler)
    }

    public func route<T>(get url: String, handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

        responseManager.route(get: url, handler: handler)
    }

    public func route<T>(get url: String, handler: @escaping (T) throws -> Any) where T: Decodable {
        responseManager.route(get: url, handler: handler)
    }

    public func route<T>(post url: String, handler: @escaping (T) throws -> Any)
        where T: Decodable {

        responseManager.route(post: url, handler: handler)
    }
}

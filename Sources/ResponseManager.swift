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

    func route(method: HTTPHeaders.Method, url: String, handler: @escaping ResponseHandler) {
        routeTree.add(route: url, forMethod: method, handler: handler)
    }

    func findHandler(for request: Request) -> ResponseHandler? {
        return routeTree.findHandler(for: request.method, in: request.path)
    }
}

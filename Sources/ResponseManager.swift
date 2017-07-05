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
    
    func get(route: String, handler: @escaping () -> Response) {
        routeTree.add(route: route, forMethod: .get){
            _ in
            return handler()
        }
    }
    
  
    func findHandler(for request: Request) -> ResponseHandler? {
        return routeTree.findHandler(for: request.method, in: request.path)
//        return routeTree.findHandler(forMethod: request.method, withPath: request.path)
    }
}

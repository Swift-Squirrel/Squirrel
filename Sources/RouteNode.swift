//
//  RouteNode.swift
//  Micros
//
//  Created by Filip Klembara on 7/3/17.
//
//

import Foundation

class RouteNode {
    
    private let route: String
    private var values: [HTTPHeaders.Method: ResponseHandler] = [:]
    
    private var childrens = [RouteNode]() {
        didSet {
            childrens.sort {
                $0.route < $1.route
            }
        }
    }

    init(route: String) {
        self.route = route
    }
    
    func addNode(routes: [String], method: HTTPHeaders.Method, handler: @escaping ResponseHandler) throws {
        for child in childrens {
            if child.route == routes.first! {
                var newRoutes = routes
                newRoutes.remove(at: 0)
                if newRoutes.isEmpty {
                    try child.set(method: method, handler: handler)
                } else {
                    try child.addNode(routes: newRoutes, method: method, handler: handler)
                }
                return
            }
        }
        
        let newNode = RouteNode(route: routes.first!)
        childrens.append(newNode)
        var newRoutes = routes
        newRoutes.remove(at: 0)
        if newRoutes.isEmpty {
            try newNode.set(method: method, handler: handler)
        } else {
            try newNode.addNode(routes: newRoutes, method: method, handler: handler)
        }
    }
    
    func set(method: HTTPHeaders.Method, handler: @escaping ResponseHandler) throws {
        guard values[method] == nil else {
            throw e.unknownError
        }
        
        values[method] = handler
    }
    
    func findHandler(for method: HTTPHeaders.Method, in routes: [String]) -> ResponseHandler? {
        guard routes.count > 0 else {
            return nil
        }
        
        if routes.count == 1 {
            return values[method]
        }
        var rs = routes
        rs.remove(at: 0)
        for child in childrens {
            if child.route == rs.first! {
                return child.findHandler(for: method, in: rs)
            }
        }
        return nil
    }
    
    
}

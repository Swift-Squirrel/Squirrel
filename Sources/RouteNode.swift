//
//  RouteNode.swift
//  Micros
//
//  Created by Filip Klembara on 7/3/17.
//
//

import Foundation

class RouteNode {
    
    let route: String
    
    private var values: [HTTPHeaders.Method: ResponseHandler] = [:]
    
    private var defaultHandlers: [HTTPHeaders.Method: ResponseHandler] = [:]
    
    private var childrens = [RouteNode]()
    
    private var dynamicNode: DynamicRouteNode? = nil

    init(route: String) {
        self.route = route
    }
    
    func addNode(routes: [String], method: HTTPHeaders.Method, handler: @escaping ResponseHandler) throws {
        guard routes.count > 0, let firstElem = routes.first else {
            Log.write(message: "Fatal error in adding routes\nroutes variable is empty", logGroup: .errors)
            throw e.unknownError
        }
        
        if firstElem == "*" {
            defaultHandlers[method] = handler
            return
        }
        
        if firstElem.hasPrefix(":")  {
            if dynamicNode == nil {
                dynamicNode = DynamicRouteNode(route: firstElem)
            }
            
            if let dynamicNode = self.dynamicNode {
                var newRoutes = routes
                newRoutes.remove(at: 0)
                if newRoutes.isEmpty {
                    try dynamicNode.set(method: method, handler: handler)
                } else {
                    try dynamicNode.addNode(routes: newRoutes, method: method, handler: handler)
                }
            }
            return
        }
        
        for child in childrens {
            if child.route == firstElem {
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
        
        let newNode = RouteNode(route: firstElem)
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
            return values[method] ?? defaultHandlers[method]
        }
        var rs = routes
        rs.remove(at: 0)
        for child in childrens {
            if child.route == rs.first! {
                return child.findHandler(for: method, in: rs) ?? defaultHandlers[method]
            }
        }
        if let dynamicNode = self.dynamicNode {
            return dynamicNode.findHandler(for: method, in: rs)
        }
        return defaultHandlers[method]
    }
    
    
}

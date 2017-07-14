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

    private var dynamicNodes = [DynamicRouteNode]()

    init(route: String) {
        self.route = route
    }

    func addNode(routes: [String], method: HTTPHeaders.Method, handler: @escaping ResponseHandler) throws {
        guard routes.count > 0, let firstElem = routes.first else {
            Log.write(message: "Fatal error in adding routes\nroutes variable is empty", logGroup: .errors)
            throw MyError.unknownError
        }

        if firstElem == "*" {
            defaultHandlers[method] = handler
            return
        }

        if firstElem.hasPrefix(":") {
            for node in dynamicNodes {
                if ":" + node.route == firstElem {
                    try nodeSetAdd(routes: routes, node: node, method: method, handler: handler)
                    return
                }
            }
            let newDynamicNode = DynamicRouteNode(route: firstElem)
            dynamicNodes.append(newDynamicNode)
            try nodeSetAdd(routes: routes, node: newDynamicNode, method: method, handler: handler)
            return
        }

        for child in childrens {
            if child.route == firstElem {
                try nodeSetAdd(routes: routes, node: child, method: method, handler: handler)
                return
            }
        }

        let newNode = RouteNode(route: firstElem)
        childrens.append(newNode)
        try nodeSetAdd(routes: routes, node: newNode, method: method, handler: handler)
    }

    private func nodeSetAdd(routes: [String],
                            node: RouteNode,
                            method: HTTPHeaders.Method,
                            handler: @escaping ResponseHandler
        ) throws {
        var newRoutes = routes
        newRoutes.remove(at: 0)
        if newRoutes.isEmpty {
            try node.set(method: method, handler: handler)
        } else {
            try node.addNode(routes: newRoutes, method: method, handler: handler)
        }
    }

    func set(method: HTTPHeaders.Method, handler: @escaping ResponseHandler) throws {
        guard values[method] == nil else {
            throw MyError.unknownError
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
        //        if let dynamicNode = self.dynamicNodes {
        //            return dynamicNode.findHandler(for: method, in: rs)
        //        }
        for node in dynamicNodes {
            if let handler = node.findHandler(for: method, in: rs) {
                return handler
            }
        }
        return defaultHandlers[method]
    }
}

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

    private var values: [RequestLine.Method: AnyResponseHandler] = [:]

    private var defaultHandlers: [RequestLine.Method: AnyResponseHandler] = [:]

    private var childrens = [RouteNode]()

    private var dynamicNodes = [DynamicRouteNode]()

    init(route: String) {
        self.route = route.lowercased()
    }

    func addNode(
        routes: [String],
        method: RequestLine.Method,
        handler: @escaping AnyResponseHandler)
        throws {

        guard routes.count > 0, let firstElem = routes.first else {
            log.error("Fatal error in adding routes, routes variable is empty")
            throw RouteError(kind: .addNodeError)
        }

        if firstElem == "*" {
            try setDefault(method: method, handler: handler)
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
                            method: RequestLine.Method,
                            handler: @escaping AnyResponseHandler) throws {
        var newRoutes = routes
        newRoutes.remove(at: 0)
        if newRoutes.isEmpty {
            try node.set(method: method, handler: handler)
        } else {
            try node.addNode(routes: newRoutes, method: method, handler: handler)
        }
    }

    private func setDefault(
        method: RequestLine.Method,
        handler: @escaping AnyResponseHandler)
        throws {

        guard defaultHandlers[method] == nil else {
            throw RouteError(kind: .methodHandlerOverwrite)
        }
        defaultHandlers[method] = handler
    }

    func set(method: RequestLine.Method, handler: @escaping AnyResponseHandler) throws {
        guard values[method] == nil else {
            throw RouteError(kind: .methodHandlerOverwrite)
        }
        values[method] = handler
    }

    func findHandler(for method: RequestLine.Method, in routes: [String])
        throws -> AnyResponseHandler? {

        guard routes.count > 0 else {
            return nil
        }

        if routes.count == 1 {
            guard let handler = values[method] ?? defaultHandlers[method] else {
                if values.count == 0 && defaultHandlers.count == 0 {
                    return nil
                }
                var methods: [RequestLine.Method] = values.keys.flatMap({ $0 })
                methods.append(contentsOf: defaultHandlers.keys.flatMap({ $0 }))
                throw HTTPError(
                    status: .notAllowed(allowed: methods),
                    description: "Method is not allowed")
            }
            return handler
        }
        var rs = routes
        rs.remove(at: 0)
        for child in childrens {
            if child.route == rs.first!.lowercased() {
                guard let handler = try child.findHandler(for: method, in: rs)
                    ?? defaultHandlers[method] else {

                        return nil
                }
                return handler
            }
        }
        for node in dynamicNodes {
            if let handler = try node.findHandler(for: method, in: rs) {
                return handler
            }
        }
        return defaultHandlers[method]
    }
}

//
//  RouteNode.swift
//  Micros
//
//  Created by Filip Klembara on 7/3/17.
//
//

import Foundation

class RouteNode {

    let name: String

    var fullName: String {
        return name
    }

    private var values: [RequestLine.Method: AnyResponseHandler] = [:]

    private var defaultHandlers: [RequestLine.Method: AnyResponseHandler] = [:]

    private var children = [RouteNode]()

    private var dynamicNodes = [DynamicRouteNode]()

    func routes(prefix: String) -> [(route: String, methods:[RequestLine.Method])] {
        let route: String
        let newPrefix: String
        if name == "/" {
            route = "/"
            newPrefix = "/"
        } else {
            route = "\(prefix)\(fullName)"
            newPrefix = "\(route)/"
        }
        var result = [(route: String, methods:[RequestLine.Method])]()
        if !values.isEmpty {
            result.append((route, values.map { $0.key }))
        }
        let childenRoutes = children.flatMap { $0.routes(prefix: newPrefix) }
        if !childenRoutes.isEmpty {
            result.append(contentsOf: childenRoutes)
        }
        let dynamicRoutes = dynamicNodes.flatMap { $0.routes(prefix: newPrefix) }
        if !dynamicNodes.isEmpty {
            result.append(contentsOf: dynamicRoutes)
        }
        if !defaultHandlers.isEmpty {
            result.append(("\(newPrefix)*", defaultHandlers.map { $0.key }))
        }
        return result
    }

    init(route: String) {
        self.name = route.lowercased()
    }

    func drop(method: RequestLine.Method, onReversed components: [String]) {
        var components = components
        guard let nodeName = components.popLast() else {
            return
        }
        guard fullName == nodeName else {
            return
        }

        if let childName = components.last {
            if childName == "*" {
                defaultHandlers.removeValue(forKey: method)
            } else if childName.first == ":" {
                var index = dynamicNodes.startIndex
                while index < dynamicNodes.endIndex {
                    let child = dynamicNodes[index]
                    if child.fullName == childName {
                        child.drop(method: method, onReversed: components)
                        if child.isEmpty {
                            let _ = dynamicNodes.remove(at: index)
                        }
                        break
                    }
                    index += 1
                }
            } else {
                var index = children.startIndex
                while index < children.endIndex {
                    let child = children[index]
                    if child.name == childName {
                        child.drop(method: method, onReversed: components)
                        if child.isEmpty {
                            let _ = children.remove(at: index)
                        }
                        break
                    }
                    index += 1
                }
            }
        } else {
            values.removeValue(forKey: method)
        }
    }

    var isEmpty: Bool {
        guard children.isEmpty && dynamicNodes.isEmpty else {
            return false
        }
        guard values.isEmpty && defaultHandlers.isEmpty else {
            return false
        }
        return true
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
                if ":" + node.name == firstElem {
                    try nodeSetAdd(routes: routes, node: node, method: method, handler: handler)
                    return
                }
            }
            let newDynamicNode = DynamicRouteNode(route: firstElem)
            dynamicNodes.append(newDynamicNode)
            try nodeSetAdd(routes: routes, node: newDynamicNode, method: method, handler: handler)
            return
        }

        for child in children {
            if child.name == firstElem {
                try nodeSetAdd(routes: routes, node: child, method: method, handler: handler)
                return
            }
        }

        let newNode = RouteNode(route: firstElem)
        children.append(newNode)
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
        for child in children {
            if child.name == rs.first!.lowercased() {
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

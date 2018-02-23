//
//  RouteTree.swift
//  Micros
//
//  Created by Filip Klembara on 7/2/17.
//
//

import Foundation

class RouteTree {
    private var root: RouteNode? = nil

    var allRoutes: [RouteDescriptor] {
        guard let root = root else {
            return []
        }
        return root.routes(prefix: "").map { RouteDescriptor(route: $0.route, methods: $0.methods) }
    }

    func drop(method: RequestLine.Method, on route: String) {
        log.debug("Removing route (\(route)) for method \(method.rawValue) ")
        guard let node = root else {
            log.debug("\tRoute \(route) does not exists")
            return
        }
        var route = route
        if route.first != "/" {
            route = "/\(route)"
        }
        var components = route.components(separatedBy: "/")
        guard !components.isEmpty else {
            return
        }
        components[components.startIndex] = "/"
        node.drop(method: method, onReversed: components.reversed())
    }

    func add(
        route: String,
        forMethod method: RequestLine.Method,
        handler: @escaping AnyResponseHandler) {

        log.debug("Adding route for method \(method.rawValue) in route: \(route)")

        guard !(route.contains("/./") || !route.hasPrefix("/") || route.contains("/../")) else {
            let msg = "Route can not contains \"/./\""
                + " or \"/../\" and must has prefix with \"/\""
            log.error(msg)
            fatalError(msg)
        }

        if route == "/" {
            if root == nil {
                root = RouteNode(route: "/")
            }
            do {
                try root!.set(method: method, handler: handler)
            } catch let error as RouteError {
                log.error(error.description)
                fatalError(error.description)
            } catch let error {
                log.error(error.localizedDescription)
                fatalError(error.localizedDescription)
            }
        } else {
            let routes: [String] = route.components(separatedBy: "/")
                .filter { $0 != "" }.map { (route: String) -> String in

                if route.first == ":" {
                    return route
                } else {
                    return route.lowercased()
                }
             }
            if self.root == nil {
                self.root = RouteNode(route: "/")
            }

            let root = self.root!
            do {
                try root.addNode(routes: routes, method: method, handler: handler)
            } catch let error as RouteError {
                log.error(error.description)
                fatalError(error.description)
            } catch let error {
                log.error(error.localizedDescription)
                fatalError(error.localizedDescription)
            }
        }
    }

    func findHandler(
        for method: RequestLine.Method,
        in route: String)
        throws -> AnyResponseHandler? {

        guard route.hasPrefix("/") else {
            log.error("Route is without prefix \"/\"")
            throw HTTPError(status: .badRequest, description: "Route is without prefix '/'")
        }

        var routes = route.components(separatedBy: "/").filter { $0 != "" }

        var i = 0
        for r in routes {
            if r == "." {
                routes.remove(at: i)
            } else if r == ".." {
                if i == 0 {
                    i = -1
                    break
                }
                routes.remove(at: i)
                routes.remove(at: i - 1)
                i -= 1
            } else {
                i += 1
            }
        }

        if i < 0 {
            routes.removeAll()
        }

        routes.insert("/", at: 0)

        return try root?.findHandler(for: method, in: routes)
    }
}

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

    func add(
        route: String,
        forMethod method: RequestLine.Method,
        handler: @escaping AnyResponseHandler) {

        log.debug("Adding route for method \(method.rawValue) in route: \(route)")

        guard !(route.contains("/./") || !route.hasPrefix("/") || route.contains("/../")) else {
            log.error("Route can not contains with \"/./\""
                + " or \"/../\" and must has prefix with \"/\"")
            exit(1)
        }

        if route == "/" {
            if root == nil {
                root = RouteNode(route: "/")
            }
            do {
                try root!.set(method: method, handler: handler)
            } catch let error as RouteError {
                log.error(error.description)
                exit(1)
            } catch let error {
                log.error(error.localizedDescription)
                exit(1)
            }
        } else {
            let routes = route.components(separatedBy: "/").filter { $0 != "" }
            if self.root == nil {
                self.root = RouteNode(route: "/")
            }

            let root = self.root!
            do {
                try root.addNode(routes: routes, method: method, handler: handler)
            } catch let error as RouteError {
                log.error(error.description)
                exit(1)
            } catch let error {
                log.error(error.localizedDescription)
                exit(1)
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

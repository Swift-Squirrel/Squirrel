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

    func add(route: String, forMethod method: HTTPHeaders.Method, handler: @escaping AnyResponseHandler) {
        Log.write(message: "Adding route for method \(method.rawValue) in route: \(route)", logGroup: .debug)

        guard !(route.contains("/./") || !route.hasPrefix("/") || route.contains("/../")) else {
            Log.write(
                message: "Route can not contains with \"/./\" or \"/../\" and must has prefix with \"/\"",
                logGroup: .errors
            )
            exit(1)
        }

        if route == "/" {
            if root == nil {
                root = RouteNode(route: "/")
            }
            do {
                try root!.set(method: method, handler: handler)
            } catch let error as RouteError {
                Log.write(
                    message: error.description,
                    logGroup: .errors
                )
                exit(1)
            } catch let error {
                Log.write(
                    message: error.localizedDescription,
                    logGroup: .errors
                )
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
                Log.write(
                    message: error.description,
                    logGroup: .errors
                )
                exit(1)
            } catch let error {
                Log.write(
                    message: error.localizedDescription,
                    logGroup: .errors
                )
                exit(1)
            }
        }
    }

    func findHandler(for method: HTTPHeaders.Method, in route: String) throws -> AnyResponseHandler? {
        guard route.hasPrefix("/") else {
            Log.write(message: "Route is without prefix \"/\"", logGroup: .errors)
            throw HTTPError(status: .badRequest, description: "Route is without prefix '/'")
        }

        var routes = route.components(separatedBy: "/").filter { $0 != "" }

        var i = 0
        for r in routes {
            if r == "." {
                routes.remove(at: i)
            } else if r == ".." {
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

//
//  MiddlewareGroup.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/12/17.
//

/// Route group
public protocol RouteGroup {
    var middlewareGroup: [Middleware] { get }
    var url: String { get }
}

// MARK: - Grouping function
public extension RouteGroup {
    /// Group routes under base url and middlewares
    ///
    /// - Parameters:
    ///   - url: Group url (default: "")
    ///   - middlewares: Middlewares (default: [])
    ///   - routes: Closure with routes
    /// - Returns: New group for future grouping
    @discardableResult
    public func group(
        _ url: String = "",
        middlewares: [Middleware] = [],
        routes: (Router) -> Void) -> RouteGroup {

        let router = CommonRouter(mergeURL(with: url), middlewares: middlewareGroup + middlewares)
        routes(router)
        return router
    }

    func mergeURL(with url: String) -> String {
        var left = self.url
        var right = url

        if left.last == "/" {
            left = left.dropLast().description
        }
        if left.first != "/" && !left.isEmpty {
            left = "/\(left)"
        }
        if right.last == "/" {
            right = left.dropLast().description
        }
        if right.first != "/" {
            right = "/\(right)"
        }
        return left + right
    }
}

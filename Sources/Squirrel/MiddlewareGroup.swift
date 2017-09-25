//
//  MiddlewareGroup.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/12/17.
//

/// Middleware group
public protocol MiddlewareGroup {
    var middlewareGroup: [Middleware] { get }
}

// MARK: - Grouping function
public extension MiddlewareGroup {

    /// Group routes of global and given middlewares
    ///
    /// - Parameters:
    ///   - middlewares: Middlewares (default: [])
    ///   - routes: Closure with routes
    /// - Returns: Middleware group for future grouping
    @discardableResult
    public func group(
        middlewares: [Middleware] = [],
        routes: (Router) -> Void) -> MiddlewareGroup {

        let router = CommonRouter(middlewares: middlewareGroup + middlewares)
        routes(router)
        return router
    }

    /// Group routes of global and given group
    ///
    /// - Parameters:
    ///   - middlewareGroup: Middleware group
    ///   - routes: Closure with routes
    /// - Returns: Middleware group for future grouping
    public func group(_ middlewareGroup: MiddlewareGroup) -> MiddlewareGroup {
        return self + middlewareGroup
    }
}

/// Merge global middlewares of given groups and returns new group with merged middlewares
///
/// - Parameters:
///   - lhs: First middleware group
///   - rhs: Last middleware group
/// - Returns: Merged groupers
public func +(lhs: MiddlewareGroup, rhs: MiddlewareGroup) -> MiddlewareGroup {
    // swiftlint:disable:previous operator_whitespace

    return CommonRouter(middlewares: lhs.middlewareGroup + rhs.middlewareGroup)
}

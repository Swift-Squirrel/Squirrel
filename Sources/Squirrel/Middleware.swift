//
//  Middleware.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/12/17.
//

/// Middleware protocol
public protocol Middleware {
    /// Middleware
    ///
    /// - Parameters:
    ///   - request: HTTP request
    ///   - next: Next handler
    /// - Returns: Result of chaining
    /// - Throws: Custom errors
    func respond(to request: Request, next: AnyResponseHandler) throws -> Any
}

func chain(middlewares: [Middleware], handler: @escaping AnyResponseHandler) -> AnyResponseHandler {
    guard middlewares.count > 0 else {
        return handler
    }

    let handlers = middlewares.reversed()

    return handlers.reduce(handler, { (nextResponse, nextMiddleware) -> AnyResponseHandler in
        return {
            request in
            return try nextMiddleware.respond(to: request, next: nextResponse)
        }
    })
}

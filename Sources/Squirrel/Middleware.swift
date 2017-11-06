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

/// Add headers to stop caching
public struct ProtectedPageMiddleware: Middleware {
    /// Call `next` and add headers important to stop storing clientside cache
    ///
    /// - Parameters:
    ///   - request: Request
    ///   - next: Next handler
    /// - Returns: `Response` with important headers
    /// - Throws: Rethrows and parsing errors
    public func respond(to request: Request, next: (Request) throws -> Any) throws -> Any {
        let anyResponse = try next(request)
        let response = try Response.parseAnyResponse(any: anyResponse)
        response.headers[.cacheControl] = "nocache, no-store, max-age=0, must-revalidate"
        response.headers[.pragma] = "no-cache"
        response.headers[.expires] = "Fri, 01 Jan 1990 00:00:00 GMT"
        return response
    }

    /// Constructs middleware
    public init() {

    }
}

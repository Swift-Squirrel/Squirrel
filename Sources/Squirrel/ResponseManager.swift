//
//  ResponseManager.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation

class ResponseManager {

    static let sharedInstance = ResponseManager()

    private var routeTree = RouteTree()

    private init() {
    }

    var allRoutes: [RouteDescriptor] {
        return routeTree.allRoutes
    }

    func route(
        method: RequestLine.Method,
        url: String,
        middlewares: [Middleware],
        handler: @escaping AnyResponseHandler) {

        let handler = chain(middlewares: middlewares, handler: handler)
        routeTree.add(route: url, forMethod: method, handler: handler)
    }

    func findHandler(for request: Request) throws -> AnyResponseHandler? {
        return try routeTree.findHandler(for: request.method, in: request.path)
    }
}

public protocol SessionDecodable: Decodable {
    
}

// MARK: - Route methods
extension ResponseManager {

    func drop(method: RequestLine.Method, on route: String) {
        routeTree.drop(method: method, on: route)
    }

//    func route(method: RequestLine.Method,
//               url: String,
//               middlewares: [Middleware],
//               handler: @escaping () throws -> Any) {
//        route(method: method, url: url, middlewares: middlewares) { _ in
//            return try handler()
//        }
//    }

//    func route(method: RequestLine.Method,
//               url: String,
//               middlewares: [Middleware],
//               handler: @escaping () throws -> Any) {
//        route(method: method, url: url, middlewares: middlewares) { _ in
//            return try handler()
//        }
//    }

//    func route<T: Decodable>(method: RequestLine.Method,
//        get url: String,
//        middlewares: [Middleware],
//        handler: @escaping (T) throws -> Any) {
//
////        let closure: AnyResponseHandler =
//        route(method: method, url: url, middlewares: middlewares) { (req: Request) in
//            let converted = try ResponseManager.convertParameters(request: req, type: T.self)
//            return try handler(converted)
//        }
//    }

}

// TODO remove
/*
// MARK: - Get method
extension ResponseManager {

    func route(
        get url: String,
        middlewares: [Middleware],
        handler: @escaping (Request) throws -> Any) {

        route(method: .get, url: url, middlewares: middlewares, handler: handler)
    }

    func route(
        get url: String,
        middlewares: [Middleware],
        handler: @escaping () throws -> Any) {

        route(get: url, middlewares: middlewares) { (_ :Request) in
            return try handler()
        }
    }

    func route<T>(
        get url: String,
        middlewares: [Middleware],
        handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

            let closure: AnyResponseHandler = {
                [unowned self] (req: Request) in
                let converted = try self.convertParameters(request: req, type: T.self)
                return try handler(req, converted)
            }
            route(get: url, middlewares: middlewares, handler: closure)
    }

 func route<T>(
 get url: String,
 middlewares: [Middleware],
 handler: @escaping (T) throws -> Any) where T: Decodable {

 let closure: AnyResponseHandler = {
 [unowned self] (req: Request) in
 let converted = try self.convertParameters(request: req, type: T.self)
 return try handler(converted)
 }
 route(get: url, middlewares: middlewares, handler: closure)
 }
}
// MARK: - Post method
extension ResponseManager {
    func route(
        post url: String,
        middlewares: [Middleware],
        handler: @escaping (Request) throws -> Any) {

        route(method: .post, url: url, middlewares: middlewares, handler: handler)
    }

    func route(
        post url: String,
        middlewares: [Middleware],
        handler: @escaping () throws -> Any) {

        route(post: url, middlewares: middlewares) { (_ :Request) in
            return try handler()
        }
    }

    func route<T>(
        post url: String,
        middlewares: [Middleware],
        handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

            let closure: AnyResponseHandler = {
                [unowned self] (req: Request) in
                let converted = try self.convertParameters(request: req, type: T.self)
                return try handler(req, converted)
            }
            route(post: url, middlewares: middlewares, handler: closure)
    }

    func route<T>(
        post url: String,
        middlewares: [Middleware],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        let closure: AnyResponseHandler = {
            [unowned self] (req: Request) in
            let converted = try self.convertParameters(request: req, type: T.self)
            return try handler(converted)
        }
        route(post: url, middlewares: middlewares, handler: closure)
    }
}

// MARK: - PUT method
extension ResponseManager {
    func route(
        put url: String,
        middlewares: [Middleware],
        handler: @escaping (Request) throws -> Any) {

        route(method: .put, url: url, middlewares: middlewares, handler: handler)
    }

    func route(
        put url: String,
        middlewares: [Middleware],
        handler: @escaping () throws -> Any) {

        route(put: url, middlewares: middlewares) { (_ :Request) in
            return try handler()
        }
    }

    func route<T>(
        put url: String,
        middlewares: [Middleware],
        handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

            let closure: AnyResponseHandler = {
                [unowned self] (req: Request) in
                let converted = try self.convertParameters(request: req, type: T.self)
                return try handler(req, converted)
            }
            route(put: url, middlewares: middlewares, handler: closure)
    }

    func route<T>(
        put url: String,
        middlewares: [Middleware],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        let closure: AnyResponseHandler = {
            [unowned self] (req: Request) in
            let converted = try self.convertParameters(request: req, type: T.self)
            return try handler(converted)
        }
        route(put: url, middlewares: middlewares, handler: closure)
    }
}

// MARK: - DELETE method
extension ResponseManager {
    func route(
        delete url: String,
        middlewares: [Middleware],
        handler: @escaping (Request) throws -> Any) {

        route(method: .delete, url: url, middlewares: middlewares, handler: handler)
    }

    func route(
        delete url: String,
        middlewares: [Middleware],
        handler: @escaping () throws -> Any) {

        route(delete: url, middlewares: middlewares) { (_ :Request) in
            return try handler()
        }
    }

    func route<T>(
        delete url: String,
        middlewares: [Middleware],
        handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

            let closure: AnyResponseHandler = {
                [unowned self] (req: Request) in
                let converted = try self.convertParameters(request: req, type: T.self)
                return try handler(req, converted)
            }
            route(delete: url, middlewares: middlewares, handler: closure)
    }

    func route<T>(
        delete url: String,
        middlewares: [Middleware],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        let closure: AnyResponseHandler = {
            [unowned self] (req: Request) in
            let converted = try self.convertParameters(request: req, type: T.self)
            return try handler(converted)
        }
        route(delete: url, middlewares: middlewares, handler: closure)
    }
}

// MARK: - PATCH method
extension ResponseManager {
    func route(
        patch url: String,
        middlewares: [Middleware],
        handler: @escaping (Request) throws -> Any) {

        route(method: .patch, url: url, middlewares: middlewares, handler: handler)
    }

    func route(
        patch url: String,
        middlewares: [Middleware],
        handler: @escaping () throws -> Any) {

        route(patch: url, middlewares: middlewares) { (_ :Request) in
            return try handler()
        }
    }

    func route<T>(
        patch url: String,
        middlewares: [Middleware],
        handler: @escaping (Request, T) throws -> Any)
        where T: Decodable {

            let closure: AnyResponseHandler = {
                [unowned self] (req: Request) in
                let converted = try self.convertParameters(request: req, type: T.self)
                return try handler(req, converted)
            }
            route(patch: url, middlewares: middlewares, handler: closure)
    }

    func route<T>(
        patch url: String,
        middlewares: [Middleware],
        handler: @escaping (T) throws -> Any) where T: Decodable {

        let closure: AnyResponseHandler = {
            [unowned self] (req: Request) in
            let converted = try self.convertParameters(request: req, type: T.self)
            return try handler(converted)
        }
        route(patch: url, middlewares: middlewares, handler: closure)
    }
}
 */

// MARK: - Convertions
extension ResponseManager {
    static func convertParameters<T: Decodable>(request: Request) throws -> T {

        var values = request.urlParameters

        if request.method == RequestLine.Method.post {
            for (k, v) in request.postParameters {
                if values[k] == nil {
                    values[k] = v
                }
            }
        }
        for (k, v) in request.queryParameters {
            if values[k] == nil {
                values[k] = v
            }
        }

        let decoder = KeyValueDecoder()
        guard let decoded = try? decoder.decode(T.self, from: values) else {
            throw HTTPError(
                status: .badRequest,
                description: "Wrong parameters type or missing parameters")
        }
        return decoded
    }

    static func convertSessionParameters<T: SessionDecodable>(request: Request) throws -> T {
        let session = try request.session()
        do {
            let data = try JSONEncoder().encode(session.data)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw HTTPError(status: .badRequest,
                            description: "Wrong parameters type or missing parameters")
        }
    }
}

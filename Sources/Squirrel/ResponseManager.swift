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

    private init() { }

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

/// Protocol used as constrain in route methods
public protocol SessionDecodable: Decodable { }

/// Protocol used as constrain in route methods
public protocol BodyDecodable: Decodable { }

// MARK: - Route methods
extension ResponseManager {

    func drop(method: RequestLine.Method, on route: String) {
        routeTree.drop(method: method, on: route)
    }
}

// MARK: - Convertions
extension ResponseManager {
    static func convertParameters<T: Decodable>(request: Request) throws -> T {

        var values = request.urlParameters

        for (key, value) in request.queryParameters where values[key] == nil {
            values[key] = value
        }

        let decoder = KeyValueDecoder()
        do {
            let decoded = try decoder.decode(T.self, from: values)
            return decoded
        } catch let error {
            throw HTTPError(.badRequest,
                description: "Wrong parameters type or missing parameters - \(error)")
        }
    }

    static func convertBodyParameters<T: BodyDecodable>(request: Request) throws -> T {

        request.headers.forEach { (key, value) in
            print("\(key): \(value)")
        }

        guard let contentType = request.headers[.contentType] else {
            throw HTTPError(.unsupportedMediaType, description: "Missing Content-Type header")
        }
        let decoded: T
        switch contentType {
        case .json:
            do {
                decoded = try JSONDecoder().decode(T.self, from: request.body)
            } catch let error {
                throw HTTPError(.badRequest,
                                description: "Wrong parameters type or missing "
                                    + "parameters - \(error)")
            }
        case .formUrlencoded:
            do {
                let values = request.postParameters
                decoded = try KeyValueDecoder().decode(T.self, from: values)
            } catch let error {
                throw HTTPError(.badRequest,
                                description: "Wrong parameters type or missing "
                                    + "parameters - \(error)")
            }
        default:
            throw HTTPError(.unsupportedMediaType,
                            description: "Content-Type: \(contentType) is not supported")
        }
        return decoded
    }

    static func convertSessionParameters<T: SessionDecodable>(request: Request) throws -> T {
        let session = try request.session()
        do {
            let data = try JSONEncoder().encode(session.data)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw HTTPError(.badRequest,
                            description: "Wrong parameters type or missing parameters")
        }
    }
}

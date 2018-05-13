//
//  Router+routing.swift
//  Squirrel'n//
//  Created by Filip Klembara on 4/30/18.
//

// swiftlint:disable trailing_whitespace
// swiftlint:disable line_length
// swiftlint:disable identifier_name
// swiftlint:disable file_length

// MARK: - routes
extension Router {
    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func get(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { _ in
                
                return try handler()
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    public func get(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                return try handler(request)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    public func get<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(params)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    public func get<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(bodyParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    public func get(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(session)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    public func get<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - builder: builder for custom struct/class created from request
    public func get<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(_builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    public func get<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(request, params)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    public func get<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, bodyParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func get<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(params, bodyParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    public func get(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(request, session)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func get<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, session)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func get<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(bodyParams, session)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    public func get<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func get<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func get<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func get<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(session, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - builder: builder for custom struct/class created from request
    public func get<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(request, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func get<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func get<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(session, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func get<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, params, bodyParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func get<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, session)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func get<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, bodyParams, session)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func get<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, bodyParams, session)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func get<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func get<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func get<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func get<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, session, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func get<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, session, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func get<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, session, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func get<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func get<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, session, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, session, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func get<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(session, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func get<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, bodyParams, session)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func get<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func get<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, session, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func get<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, session, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func get<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, session, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func get<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, session, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, session, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func get<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, session, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for get method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func get<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .get,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func post(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { _ in
                
                return try handler()
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    public func post(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                return try handler(request)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    public func post<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(params)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    public func post<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(bodyParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    public func post(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(session)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    public func post<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - builder: builder for custom struct/class created from request
    public func post<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(_builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    public func post<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(request, params)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    public func post<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, bodyParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func post<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(params, bodyParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    public func post(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(request, session)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func post<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, session)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func post<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(bodyParams, session)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    public func post<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func post<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func post<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func post<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(session, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - builder: builder for custom struct/class created from request
    public func post<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(request, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func post<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func post<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(session, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func post<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, params, bodyParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func post<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, session)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func post<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, bodyParams, session)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func post<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, bodyParams, session)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func post<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func post<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func post<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func post<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, session, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func post<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, session, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func post<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, session, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func post<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func post<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, session, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, session, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func post<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(session, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func post<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, bodyParams, session)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func post<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func post<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, session, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func post<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, session, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func post<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, session, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func post<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, session, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, session, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func post<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, session, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for post method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func post<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .post,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func put(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { _ in
                
                return try handler()
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    public func put(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                return try handler(request)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    public func put<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(params)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    public func put<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(bodyParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    public func put(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(session)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    public func put<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - builder: builder for custom struct/class created from request
    public func put<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(_builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    public func put<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(request, params)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    public func put<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, bodyParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func put<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(params, bodyParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    public func put(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(request, session)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func put<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, session)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func put<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(bodyParams, session)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    public func put<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func put<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func put<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func put<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(session, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - builder: builder for custom struct/class created from request
    public func put<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(request, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func put<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func put<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(session, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func put<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, params, bodyParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func put<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, session)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func put<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, bodyParams, session)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func put<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, bodyParams, session)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func put<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func put<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func put<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func put<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, session, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func put<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, session, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func put<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, session, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func put<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func put<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, session, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, session, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func put<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(session, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func put<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, bodyParams, session)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func put<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func put<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, session, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func put<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, session, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func put<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, session, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func put<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, session, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, session, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func put<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, session, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for put method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func put<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .put,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func delete(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { _ in
                
                return try handler()
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    public func delete(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                return try handler(request)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    public func delete<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(params)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    public func delete<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(bodyParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    public func delete(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(session)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    public func delete<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - builder: builder for custom struct/class created from request
    public func delete<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(_builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    public func delete<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(request, params)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    public func delete<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, bodyParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func delete<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(params, bodyParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    public func delete(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(request, session)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func delete<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, session)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func delete<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(bodyParams, session)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    public func delete<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func delete<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func delete<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func delete<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(session, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - builder: builder for custom struct/class created from request
    public func delete<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(request, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func delete<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func delete<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(session, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func delete<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, params, bodyParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func delete<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, session)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func delete<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, bodyParams, session)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func delete<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, bodyParams, session)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func delete<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func delete<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func delete<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func delete<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, session, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func delete<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, session, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func delete<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, session, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func delete<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func delete<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, session, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, session, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func delete<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(session, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func delete<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, bodyParams, session)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func delete<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func delete<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, session, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func delete<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, session, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func delete<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, session, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func delete<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, session, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, session, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func delete<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, session, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for delete method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func delete<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .delete,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    public func patch(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping () throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { _ in
                
                return try handler()
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    public func patch(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                return try handler(request)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    public func patch<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(params)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    public func patch<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(bodyParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    public func patch(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(session)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    public func patch<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - builder: builder for custom struct/class created from request
    public func patch<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(_builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    public func patch<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                return try handler(request, params)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    public func patch<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, bodyParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func patch<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(params, bodyParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    public func patch(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                return try handler(request, session)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func patch<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, session)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func patch<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(bodyParams, session)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    public func patch<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func patch<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func patch<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func patch<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(session, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - builder: builder for custom struct/class created from request
    public func patch<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let _builder: C = try builder(request)
                return try handler(request, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func patch<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func patch<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(session, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    public func patch<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                return try handler(request, params, bodyParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    public func patch<T: Decodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, session)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func patch<B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, bodyParams, session)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func patch<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(params, bodyParams, session)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    public func patch<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func patch<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func patch<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func patch<S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, session, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func patch<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, session, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func patch<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(bodyParams, session, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func patch<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func patch<C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, session, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, session, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func patch<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(session, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    public func patch<T: Decodable, B: BodyDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                return try handler(request, params, bodyParams, session)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    public func patch<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func patch<T: Decodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, session, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func patch<B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, bodyParams, session, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func patch<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, session, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func patch<B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, session, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, session, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    public func patch<T: Decodable, B: BodyDecodable, S: SessionDecodable>(
        _ url: String,
        middlewares: [Middleware] = [],
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                return try handler(request, params, bodyParams, session, sessionParams)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, B: BodyDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, session, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(params, bodyParams, session, sessionParams, _builder)
        }
    }

    /// Add route for patch method
    ///
    /// - Parameters:
    ///   - url: Url of route
    ///   - middlewares: Array of Middlewares
    ///   - handler: Response handler
    ///   - request: Request class
    ///   - params: struct/class created from request query patameters
    ///   - bodyParams: struct/class created from request body
    ///   - session: Session class
    ///   - sessionParams: struct/class created from session
    ///   - builder: builder for custom struct/class created from request
    public func patch<T: Decodable, B: BodyDecodable, S: SessionDecodable, C>(
        _ url: String,
        middlewares: [Middleware] = [],
        builder: @escaping (_ request: Request) throws -> C,
        handler: @escaping (_ request: Request, _ params: T, _ bodyParams: B, _ session: Session, _ sessionParams: S, _ customParam: C) throws -> Any) {

        ResponseManager.sharedInstance.route(
            method: .patch,
            url: mergeURL(with: url),
            middlewares: middlewareGroup + middlewares) { request in
                
                let params: T = try ResponseManager.convertParameters(request: request)
                let bodyParams: B = try ResponseManager.convertBodyParameters(request: request)
                let session: Session = try request.session()
                let sessionParams: S = try ResponseManager.convertSessionParameters(request: request)
                let _builder: C = try builder(request)
                return try handler(request, params, bodyParams, session, sessionParams, _builder)
        }
    }
}

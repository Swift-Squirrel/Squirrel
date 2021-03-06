//
//  ErrorHandler.swift
//  Micros
//
//  Created by Filip Klembara on 7/14/17.
//
//

import SquirrelCore

/// Error handler protocol
public protocol ErrorHandlerProtocol {
    func getResponse(for error: Error) -> ResponseProtocol?
}

/// Error handler singleton class
public class ErrorHandler {
    /// Singleton instance
    public static let sharedInstance = ErrorHandler()

    private init() {
        addError(handler: BasicErrors())
        addError(handler: HTMLConvertibleErrors())
    }
    private var handlers = [ErrorHandlerProtocol]()

    /// Add error hanler as firt in array of error handlers
    ///
    /// - Parameter handler: handler to insert
    public func addError(handler: ErrorHandlerProtocol) {
        handlers.insert(handler, at: 0)
    }

    private func findHandler(for error: Error) -> ResponseProtocol? {
        for handler in handlers {
            if let response = handler.getResponse(for: error) {
                return response
            }
        }
        return nil
    }

    private func getErrorResponse(for error: Error) -> ResponseProtocol? {
        if let handler = findHandler(for: error) {
            return handler
        }

        if let httpError = error as? HTTPConvertibleError {
            if let handler = findHandler(for: httpError.asHTTPError) {
                return handler
            }
        }
        return nil
    }

    func response(for error: Error) -> ResponseProtocol {
        guard let response = getErrorResponse(for: error) else {
            let description = String(describing: error)
            let body = """
                Internal error has occured, nothing to handle it.
                Error description:
                    '\(description)'
                """
            let escapedBody = body.escaped
            return Response(status: .internalError,
                            headers: [.contentType(.html)],
                            body: escapedBody.data(using: .utf8)!)
        }
        return response
    }
}

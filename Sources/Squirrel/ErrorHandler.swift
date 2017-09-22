//
//  ErrorHandler.swift
//  Micros
//
//  Created by Filip Klembara on 7/14/17.
//
//

import NutView

/// Error handler protocol
public protocol ErrorHandlerProtocol {
    func getResponse(for error: Error) -> Response?
}

/// Error handler singleton class
public class ErrorHandler {
    /// Singleton instance
    public static let sharedInstance = ErrorHandler()

    private init() {
        addErrorHandler(handler: BasicErrors())
        addErrorHandler(handler: ViewErrors())
        addErrorHandler(handler: ViewNutErrors())
    }
    private var handlers = [ErrorHandlerProtocol]()

    /// Add error hanler as firt in array of error handlers
    ///
    /// - Parameter handler: handler to insert
    public func addErrorHandler(handler: ErrorHandlerProtocol) {
        handlers.insert(handler, at: 0)
    }

    private func findErrorHandler(for error: Error) -> Response? {
        for handler in handlers {
            if let response = handler.getResponse(for: error) {
                return response
            }
        }
        return nil
    }

    private func getErrorResponse(for error: Error) -> Response? {
        if let handler = findErrorHandler(for: error) {
            return handler
        }

        if let httpError = error as? AsHTTPProtocol {
            if let handler = findErrorHandler(for: httpError.asHTTPError) {
                return handler
            }
        }

        return nil
    }

    func response(for error: Error) -> Response {
        guard let response = getErrorResponse(for: error) else {
            let description = String(describing: error)
            let body = """
                Internal error has occured, nothing to handle it.
                Error description:
                    '\(description)'
                """
            let escapedBody = convertToSpecialCharacters(string: body)
            return Response(status: .internalError, body: escapedBody.data(using: .utf8)!)
        }
        return response
    }

}

extension String {
    var escaped: String {
        return convertToSpecialCharacters(string: self)
    }
}

func convertToSpecialCharacters(string: String) -> String {
    var newString = string
    let char_dictionary: [String: StaticString] = [
        "&amp;" : "&(?!\\S+;)",
        "&lt;" : "<",
        "&gt;" : ">",
        "&quot;" : "\"",
        "&apos;" : "'"
    ]
    for (escaped, unescaped) in char_dictionary {
        newString = newString.replacingAll(matching: unescaped, with: escaped)
    }
    return newString
}

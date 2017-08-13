//
//  ErrorHandler.swift
//  Micros
//
//  Created by Filip Klembara on 7/14/17.
//
//

import Foundation

public protocol ErrorHandlerProtocol {
    func getResponse(for error: Error) -> Response?
}

struct BasicErrors: ErrorHandlerProtocol {
    fileprivate init() {

    }

    func getResponse(for error: Error) -> Response? {
        guard let error = error as? HTTPError else {
            return nil
        }
        if let body = error.description.data(using: .utf8) {
            return Response(status: error.status, body: body)
        } else {
            return Response(status: .internalError)
        }

    }
}

class ErrorHandler {
    public static let sharedInstance = ErrorHandler()

    private init() {
        addErrorHandler(handler: BasicErrors())
    }
    private var handlers = [ErrorHandlerProtocol]()

    public func addErrorHandler(handler: ErrorHandlerProtocol) {
        handlers.insert(handler, at: 0)
    }

    private func getErrorResponse(for error: Error) -> Response? {
        var solvingError = error
        if let asHTTPErrorProtocol = error as? AsHTTPProtocol {
            solvingError = asHTTPErrorProtocol.asHTTPError
        }
        for handler in handlers {
            if let response = handler.getResponse(for: solvingError) {
                return response
            }
        }
        return nil
    }

    func response(for error: Error) -> Response {
        guard let response = getErrorResponse(for: error) else {
            let description = String(describing: error)
//            let escaped = convertToSpecialCharacters(string: description)
            let body = "Internal error has occured, nothing to handle it.\nError description:\n'\(description)'".data(using: .utf8)!
            return Response(status: .internalError, body: body)
        }
        return response
    }

}

func convertToSpecialCharacters(string: String) -> String {
    var newString = string
    let char_dictionary = [
        "&amp;" : "&",
        "&lt;" : "<",
        "&gt;" : ">",
        "&quot;" : "\"",
        "&apos;" : "'"
    ];
    for (escaped_char, unescaped_char) in char_dictionary {
        newString = newString.replacingOccurrences(of: unescaped_char, with: escaped_char, options: NSString.CompareOptions.literal, range: nil)
    }
    return newString
}

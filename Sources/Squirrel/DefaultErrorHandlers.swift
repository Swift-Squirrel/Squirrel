//
//  DefaultErrorHandlers.swift
//  Squirrel
//
//  Created by Filip Klembara on 9/18/17.
//

import SquirrelCore

struct HTMLConvertibleErrors: ErrorHandlerProtocol {
    func getResponse(for error: Error) -> Response? {
        guard let error = error as? SquirrelHTMLConvertibleError else {
            return nil
        }
        let body = error.htmlErrorRepresentation
        if let response = try? Response(status: .internalError, html: body) {
            return response
        } else {
            return Response(status: .internalError)
        }
    }
}

struct BasicErrors: ErrorHandlerProtocol {
    func getResponse(for error: Error) -> Response? {
        guard let error = error as? HTTPError else {
            return nil
        }
        let body = htmlTemplate(title: error.status.description, body: error.description)
        if let response = try? Response(status: error.status, html: body) {
            return response
        } else {
            return Response(status: .internalError)
        }
    }
}

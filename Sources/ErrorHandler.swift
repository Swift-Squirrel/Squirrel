//
//  ErrorHandler.swift
//  Micros
//
//  Created by Filip Klembara on 7/14/17.
//
//

import Foundation

class ErrorHandler {
    static let sharedInstance = ErrorHandler()

    private init() {

    }

    func handler(for: Error) -> ResponseHandler {
        // TODO
        return {
            _ in
            return Response(
                headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
                body: "Error".data(using: .utf8)!
            )
        }
    }
    func response(for: Error) -> Response {
        // TODO
        return Response(
            headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
            body: "Error".data(using: .utf8)!
        )

    }

}

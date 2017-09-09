//
//  Response.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation
import PathKit

typealias ResponseHandler = ((Request) -> Response)

typealias AnyResponseHandler = ((Request) throws -> Any)

public class Response {

    private let routeTree = RouteTree()

    private let status: HTTPStatus

    private let httpProtocolVersion = "HTTP/1.1"

    private var headers: [String: String] = [
        HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.plain.rawValue
    ]

    private var body = Data()

    var bodyLenght: Int {
        return (Array(body)).count
    }

    public init(status: HTTPStatus) {
        self.status = status

        if let location = getLocationFor(status: status) {
            headers[HTTPHeaders.location] = location
        }

        switch status {
        case .unauthorized(let wwwAuthenticate):
            headers[HTTPHeaders.wwwAuthenticate] = wwwAuthenticate
        case .tooManyRequests(let retryAfter),
             .serviceUnavailable(let retryAfter):
            headers[HTTPHeaders.retryAfter] = retryAfter
        case .notAllowed(let allowed):
            let value = allowed.flatMap({ $0.rawValue.uppercased() }).joined(separator: ", ")
            headers[HTTPHeaders.allow] = value
        default:
            break
        }
    }

   public convenience init(status: HTTPStatus = .ok, headers: [String: String] = [:], body: Data) {
        self.init(status: status)

        self.body = body
        for (key, value) in headers {
            self.headers[key] = value
        }
    }

    private func getLocationFor(status: HTTPStatus) -> String? {
        switch status {
        case .created(let location),
             .movedPermanently(let location),
             .found(let location),
             .seeOther(let location),
             .temporaryRedirect(let location),
             .permanentRedirect(let location):

            return location.description
        default:
            return nil
        }
    }

    func setHeader(for key: String, to value: String) {
        headers[key] = value
    }

    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    public init(pathToFile path: Path) throws {

        status = .ok

        guard path.exists else {
            throw HTTPError(status: .notFound, description: "Path does not exists.")
        }

        guard path.isFile else {
            throw HTTPError(status: .notFound, description: "File not found")
        }
        body = try path.read()

        if let fileExtension = path.`extension` {
            switch fileExtension.lowercased() {
            case "json":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Application.json.rawValue
                )
            case "js":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Application.js.rawValue)

            case "jpg", "jpeg":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Image.jpeg.rawValue)
            case "png":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Image.png.rawValue)
            case "svg":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Image.svg.rawValue)

            case "css":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Text.css.rawValue)
            case "html":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Text.html.rawValue)
            case "txt":
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Text.plain.rawValue)
            default:
                setHeader(
                    for: HTTPHeaders.ContentType.contentType,
                    to: HTTPHeaders.ContentType.Text.plain.rawValue)
            }
        } else {
            // TODO
            setHeader(
                for: HTTPHeaders.ContentType.contentType,
                to: HTTPHeaders.ContentType.Text.plain.rawValue)
        }
    }
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length

    func responeHandler() -> ResponseHandler {
        return {
            _ in
            return self
        }
    }

    func rawHeader() -> Data {
        var header = httpProtocolVersion + " " + status.description + "\r\n"
        header += HTTPHeaders.contentLength + ": " + String(bodyLenght) + "\r\n"
        for (key, value) in headers {
            header += key + ": " + value + "\r\n"
        }
        header += "\r\n"
        return header.data(using: .utf8)!
    }

    func rawBody() -> Data {
        return body
    }

    func raw() -> Data {
        var res = rawHeader()
        res.append(rawBody())
        return res
    }
}

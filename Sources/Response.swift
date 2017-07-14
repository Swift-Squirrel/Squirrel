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

class Response {

    private let routeTree = RouteTree()

    private let status = HTTPHeaders.Status.s200

    private let httpProtocolVersion = "HTTP/1.1"

    private var headers = [
        HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.plain.rawValue
    ]

    private var body = Data()

    var bodyLenght: Int {
        let pom: [UInt8] = Array(body)
        return pom.count
    }

    init(headers: [String: String], body: Data) {
        self.body = body
        for (key, value) in headers {
            self.headers[key] = value
        }
    }

    func setHeader(for key: String, to value: String) {
        headers[key] = value
    }

    init() {

    }

    init(pathToFile path: Path) {
        guard path.exists else {
            let res = ErrorHandler.sharedInstance.response(for: MyError.unknownError)
            headers = res.headers
            body = res.body
            return

        }
        guard path.isFile else {
            let res = ErrorHandler.sharedInstance.response(for: MyError.unknownError)
            headers = res.headers
            body = res.body
            return
        }
        do {
            body = try path.read()
        } catch let error {
            let res = ErrorHandler.sharedInstance.response(for: error)
            headers = res.headers
            body = res.body
            return
        }
        if let fileExtension = path.`extension` {
            switch fileExtension.lowercased() {
            case "js", "json":
                setHeader(for: HTTPHeaders.ContentType.contentType, to: HTTPHeaders.ContentType.Application.js.rawValue)

            case "jpg", "jpeg":
                setHeader(for: HTTPHeaders.ContentType.contentType, to: HTTPHeaders.ContentType.Image.jpeg.rawValue)
            case "png":
                setHeader(for: HTTPHeaders.ContentType.contentType, to: HTTPHeaders.ContentType.Image.png.rawValue)

            case "css":
                setHeader(for: HTTPHeaders.ContentType.contentType, to: HTTPHeaders.ContentType.Text.css.rawValue)
            case "html":
                setHeader(for: HTTPHeaders.ContentType.contentType, to: HTTPHeaders.ContentType.Text.html.rawValue)
            case "txt":
                setHeader(for: HTTPHeaders.ContentType.contentType, to: HTTPHeaders.ContentType.Text.plain.rawValue)
            default:
                setHeader(for: HTTPHeaders.ContentType.contentType, to: HTTPHeaders.ContentType.Text.plain.rawValue)
            }
        } else {
            // TODO
            setHeader(for: HTTPHeaders.ContentType.contentType, to: HTTPHeaders.ContentType.Text.plain.rawValue)
        }

    }

    func responeHandler() -> ResponseHandler {
        return {
            _ in
            return self
        }
    }

    func rawHeader() -> Data {
        var header = httpProtocolVersion + " " + status.rawValue + "\r\n"
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

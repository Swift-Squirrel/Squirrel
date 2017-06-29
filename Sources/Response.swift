//
//  Response.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation

class Response {
    
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
    
    init(file: URL) throws {
        body = try Data(contentsOf: file)
        let fileExtension = file.pathExtension
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

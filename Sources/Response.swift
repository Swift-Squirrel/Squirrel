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
    
    private var bodyLenght: Int {
        let pom: [UInt8] = Array(body)
        return pom.count
    }
    
    init(headers: [String: String], body: String) {
        self.body = body.data(using: .utf8)!
        for (key, value) in headers {
            self.headers[key] = value
        }
    }
    init() {
        
    }
    
    
    
    func raw() -> Data {
        var header = httpProtocolVersion + " " + status.rawValue + "\r\n"
        header += HTTPHeaders.contentLength + ": " + String(bodyLenght) + "\r\n"
        for (key, value) in headers {
            header += key + ": " + value + "\r\n"
        }
        header += "\r\n"
        var res = header.data(using: .utf8)!
//        let body = "<h1>Hello world</h1>"
//        let res = "HTTP/1.1 200 OK\r\nContent-Type: text/html\r\nContent-Length: \(body.characters.count)\r\n\r\n\(body)"
        res.append(body)
        return res
    }
}

//
//  HTTPHeaders.swift
//  Micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation

enum HTTPHeaders {
    
    enum HTTPProtocol: String {
        case http11 = "HTTP/1.1"
    }
    static let contentLength = "Content-Length"
    enum ContentType {
        static let contentType = "Content-Type"
        
        enum Image: String {
            case png = "image/png"
            case jpeg = "image/jpeg"
        }
        
        enum Text: String {
            case html = "text/html"
            case plain = "text/plain"
            case css = "text/css"
        }
        
        enum Application: String {
            case js = "application/javascript"
        }
    }
    
    enum Method: String {
        case post = "POST"
        case get = "GET"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    enum Status: String {
        case s200 = "200 OK"
    }
}


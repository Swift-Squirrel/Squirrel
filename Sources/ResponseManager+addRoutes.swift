//
//  ResponseManager+addRoutes.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation

extension ResponseManager {
    func addRoutes() {
        
        get(route: "/web") { () -> Response in
            return try! Response(file: URL(fileURLWithPath: Config.sharedInstance.webRoot + "/web/index.html"))
        }
        
        get(route: "/") {
            return Response(headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue], body: "Olaaa".data(using: .utf8)!)
        }
        
//        get(route: "/*") {
//            return Response(headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue], body: "Olaaa".data(using: .utf8)!)
//        }

    }
}

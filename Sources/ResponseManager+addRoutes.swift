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

//        route(get: "/web") {
//            return try! Response(file: URL(fileURLWithPath: Config.sharedInstance.webRoot + "/web/index.html"))
//        }
//
//        route(get: "/") {
//            return Response(headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue], body: "Olaaa".data(using: .utf8)!)
//        }
        //
        route(get: "/:") {
            return Response(headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue], body: "Olaa la".data(using: .utf8)!)
        }
        route(get: "/*") {
            return Response(headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue], body: "Olaa la lalalala".data(using: .utf8)!)
        }

//        get(route: "/photos/{id}") {
//            (request) -> Response in
//            return Response(headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue], body: "photo with id".data(using: .utf8)!)
//        }
//
//        get(route: "as") { (r) in
//            return Response()
//        }


        struct asd {
            var name: String
            var age: Int
        }

        route(get: "/:name/sn/:age") { (p: asd) -> Response in
            print("ad \(p.name) \(p.age)")
            return Response(headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue], body: "ad \(p.name) \(p.age)".data(using: .utf8)!)
        }

//        route(get: "/photos/:id/:/:name") {
//            (r: Request) in
//            let id = r.getURLParameter(for: "id")!
//            let name = r.getURLParameter(for: "name")!
//            return Response(headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue], body: "photo with id: \(id) \(name)".data(using: .utf8)!)
//        }


        //        get(route: "/*") {
        //            return Response(headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue], body: "Olaaa".data(using: .utf8)!)
        //        }

    }
}

//
//  main.swift
//  micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation

Log.logging(turnedOn: true)
#if Xcode
Log.colored = false
#endif
let server = Server()

server.route(get: "/hell") {
    return "Hell! Ou!"
}

server.route(get: "/:") {
    return Response(
        headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
        body: "Olaa la".data(using: .utf8)!
    )
}
//server.route(get: "/*") {
//    return Response(
//        headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
//        body: "Olaa la lalalala".data(using: .utf8)!
//    )
//}

struct Asd {
    var name: String
    var age: Int
}

server.route(get: "/:name/sn/:age") { (p: Asd) -> Response in
    print("ad \(p.name) \(p.age)")
    return Response(
        headers: [HTTPHeaders.ContentType.contentType: HTTPHeaders.ContentType.Text.html.rawValue],
        body: "ad \(p.name) \(p.age)".data(using: .utf8)!
    )
}


try server.run()

//
//  main.swift
//  micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation
import PathKit



func main() throws {
    let server = Server()
    
    server.route(get: "/posts") { () -> Any in
        let titles = ["Dogs", "Cats", "Squirrels"]
        let res = titles.flatMap({ "<li>\($0)</li>" }).joined()
        return try Response(html: "<ul>\(res)</ul>")
    }

    server.route(get: "/posts/:id/:title/:body") { (post: Post) -> Any in
        return post
    }

    server.route(get: "/:/photo") { () -> Any in
        return try Response(pathToFile: Path(components: [Config.sharedInstance.webRoot, "squirrel.png"]))
    }

    ErrorHandler.sharedInstance.addErrorHandler(handler: My404())
    
    try server.run()

}

struct My404: ErrorHandlerProtocol {
    func getResponse(for error: Error) -> Response? {
        guard let error = error as? HTTPError else {
            return nil
        }
        guard error.status.code == HTTPStatus.notFound.code else {
            return nil
        }

        return try! Response(html: "This is my custom 404<br>\(error) not found... sorry <img src='/squirrel.png'>")
    }
}


try main()

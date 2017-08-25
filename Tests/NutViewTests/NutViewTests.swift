//
//  NutViewTests.swift
//  Squirrel
//
//  Created by Filip Klembara on 8/7/17.
//
//

import XCTest
@testable import NutView
import SquirrelConfig
import SquirrelView
import SquirrelConnector

struct Post: Model {
    var id: ObjectId? = nil

    init(title: String, body: String) {
        self.title = title
        self.body = body
    }

    var title: String
    var body: String

    var created = Date()
    var modified = Date()
}

class NutViewTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testView() {
        Connector.setConnector(host: "127.0.0.1")

        let posts = try! Post.find()
        do {
            var view = try View(name: "Posts", with: posts)
            let res = try view.getContent()
            print(res)
        } catch let error {
            XCTFail("\(error)")
        }
//        let arr: [String] = ["adin", "dva", "tri"]
//        let data: [String: Any] = ["posts": arr]
//        var view = try! View(name: "posts", with: data)
//        let res = try! view.getContent()
//        print(res)
    }

    func testExample() {
//        let interpreter = NutInterpreter(resources: Config.sharedInstance.views, storage: Config.sharedInstance.storageViews)
////        interpreter.setContent(content: "a\\(\"a\\\\s\" + 4)")
//        interpreter.setContent(content: "\n\\Title(\"asd \" + String(1))\n\nasd\n\n\\for post in posts { <li> \\(post) \\}")
////        interpreter.setContent(content: "\\\\()")
//        let tokenized = try! interpreter.tokenize()
//        print(tokenized)
//                interpreter.setContent(content: "a\\(\\\\)")
////                interpreter.setContent(content: "a\\\\()")
//        let tokenized1 = try! interpreter.tokenize()
//        print(tokenized1)

        //XCTAssertEqual(tokenized, ["a", "\\for a in b", "\\} ", "\\", "for a in c", "\\", "}", "\\"])
    }
}

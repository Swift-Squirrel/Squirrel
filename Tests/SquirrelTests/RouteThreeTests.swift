//
//  RouteThreeTests.swift
//  Micros
//
//  Created by Filip Klembara on 7/26/17.
//
//

import XCTest
import Test
@testable import Squirrel

class RouteThreeTests: XCTestCase {
    let handler: AnyResponseHandler = {(_: Request) throws -> Any in return "handler"}
    let nodeName = "/"
    let rootNode = RouteNode(route: "/")

    override func setUp() {
        super.setUp()
        log.removeAllDestinations()
    }

    func testRootNode() {
        assertTrue(rootNode.name == nodeName)

        assertNoThrow(try rootNode.set(method: .get, handler: handler))
        assertNoThrow(try rootNode.set(method: .post, handler: handler))
        assertThrowsError(try rootNode.set(method: .get, handler: handler))

        assertNil(try rootNode.findHandler(for: .get, in: []))
        assertNoThrow(try rootNode.findHandler(for: .get, in: ["/"]) != nil)
        assertNoThrow(try rootNode.findHandler(for: .post, in: ["/"]) != nil)
        assertNoThrow(try rootNode.findHandler(for: .post, in: ["/", "web"]) == nil)
        assertThrowsError(try rootNode.findHandler(for: .put, in: ["/"]))

        addStaticNodes(for: .get, in: "/web")
        addStaticNodes(for: .get, in: "/web/images")
        addStaticNodes(for: .put, in: "/web/images")
        addStaticNodes(for: .get, in: "/admin")
        addStaticNodes(for: .get, in: "/admin/statistics")

        handlerNotExists(for: .get, in: "/web/images/albums/32")
        handlerNotExists(for: .get, in: "/web/images/albums/35")
        handlerNotExists(for: .get, in: "/web/images/albums/asd")
        handlerNotExists(for: .put, in: "/web/images/albums/32")
        handlerNotExists(for: .put, in: "/web/images/albums/35")
        handlerNotExists(for: .put, in: "/web/images/albums/asd")
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", "images","albums", ":id"], method: .get, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", "images", "albums", ":id"], method: .get, handler: handler))
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", "images","albums", ":id"], method: .put, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", "images", "albums", ":id"], method: .put, handler: handler))
        handlerExists(for: .get, in: "/web/images/albums/32")
        handlerExists(for: .get, in: "/web/images/albums/35")
        handlerExists(for: .get, in: "/web/images/albums/asd")
        handlerExists(for: .put, in: "/web/images/albums/32")
        handlerExists(for: .put, in: "/web/images/albums/35")
        handlerExists(for: .put, in: "/web/images/albums/asd")

        handlerNotExists(for: .get, in: "/web/images/51")
        handlerNotExists(for: .get, in: "/web/images/asd")
        handlerNotExists(for: .get, in: "/web/images/5161")
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", "images", ":id"], method: .get, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", "images", ":id"], method: .get, handler: handler))
        handlerExists(for: .get, in: "/web/images/51")
        handlerExists(for: .get, in: "/web/images/asd")
        handlerExists(for: .get, in: "/web/images/5161")

        handlerNotExists(for: .delete, in: "/web/images/51")
        handlerNotExists(for: .delete, in: "/web/images/asd")
        handlerNotExists(for: .delete, in: "/web/images/5161")
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", "images", ":id"], method: .delete, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", "images", ":id"], method: .delete, handler: handler))
        handlerExists(for: .delete, in: "/web/images/51")
        handlerExists(for: .delete, in: "/web/images/asd")
        handlerExists(for: .delete, in: "/web/images/5161")

        handlerNotExists(for: .get, in: "/web/images/51/dsa")
        handlerNotExists(for: .get, in: "/web/images/asd/41")
        handlerNotExists(for: .get, in: "/web/images/5161/51")
        handlerNotExists(for: .put, in: "/web/images/51/dsa")
        handlerNotExists(for: .put, in: "/web/images/asd/41")
        handlerNotExists(for: .put, in: "/web/images/5161/51")
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", "images", ":id", ":a"], method: .get, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", "images", ":id", ":a"], method: .get, handler: handler))
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", "images", ":id", ":a"], method: .post, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", "images", ":id", ":a"], method: .post, handler: handler))
        handlerExists(for: .get, in: "/web/images/51/dsa")
        handlerExists(for: .get, in: "/web/images/asd/41")
        handlerExists(for: .get, in: "/web/images/5161/51")
        handlerExists(for: .put, in: "/web/images/51/dsa")
        handlerExists(for: .put, in: "/web/images/asd/41")
        handlerExists(for: .put, in: "/web/images/5161/51")
        acceptableError() {
            [weak self] in
            guard let strongSelf = self else {
                return
            }
            assertThrowsError(try strongSelf.rootNode.addNode(routes: ["/", "web", "images", ":ida", ":a"], method: .put, handler: strongSelf.handler), "Route with dynamic values doen not block new with same dynamic values order")
        }
        handlerNotExists(for: .put, in: "/web/images/ida/asd/ap")
        handlerNotExists(for: .put, in: "/web/images/15ida/a42/41")
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", "images", ":ida", ":a", ":b"], method: .put, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", "images", ":ida", ":a", ":b"], method: .put, handler: handler))
        handlerExists(for: .put, in: "/web/images/ida/asd/ap")
        handlerExists(for: .put, in: "/web/images/15ida/a42/41")

        handlerNotExists(for: .get, in: "/web/asd")
        handlerNotExists(for: .get, in: "/web/53")
        handlerNotExists(for: .get, in: "/web/1fa")
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", ":"], method: .get, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", ":"], method: .get, handler: handler))
        handlerExists(for: .get, in: "/web/asd")
        handlerExists(for: .get, in: "/web/53")
        handlerExists(for: .get, in: "/web/1fa")

        handlerNotExists(for: .put, in: "/web/asd")
        handlerNotExists(for: .put, in: "/web/53")
        handlerNotExists(for: .put, in: "/web/1fa")
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", ":"], method: .put, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", ":"], method: .put, handler: handler))
        handlerExists(for: .put, in: "/web/asd")
        handlerExists(for: .put, in: "/web/53")
        handlerExists(for: .put, in: "/web/1fa")

        handlerNotExists(for: .get, in: "/web/1fa/asd/asd/21")
        handlerNotExists(for: .get, in: "/web/1fa/as1")
        handlerNotExists(for: .get, in: "/admin/1fa/asd/asd/21")
        handlerNotExists(for: .get, in: "/admin/1fa/as1")
        assertNoThrow(try rootNode.addNode(routes: ["/", "web", "*"], method: .get, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "web", "*"], method: .get, handler: handler))
        assertNoThrow(try rootNode.addNode(routes: ["/", "admin", "*"], method: .get, handler: handler))
        assertThrowsError(try rootNode.addNode(routes: ["/", "admin", "*"], method: .get, handler: handler))
        handlerExists(for: .get, in: "/web/1fa/asd/asd/21")
        handlerExists(for: .get, in: "/web/1fa/as1")
        handlerExists(for: .get, in: "/admin/1fa/asd/asd/21")
        handlerExists(for: .get, in: "/admin/1fa/as1")

        handlerExists(for: .get, in: "/web")
        handlerExists(for: .get, in: "/web/ImaGes")
        handlerExists(for: .get, in: "/css")
        handlerExists(for: .get, in: "/admin")
        handlerExists(for: .get, in: "/admin/statistics")

        handlerNotExists(for: .get, in: "not/existing")
        let routeNotExisting = ["/", "not", "existing"]
        assertNoThrow(try rootNode.addNode(routes: routeNotExisting, method: .get, handler: handler))
        handlerExists(for: .get, in: "not/existing")
        rootNode.drop(method: .get, onReversed: routeNotExisting.reversed())
        handlerNotExists(for: .get, in: "not/existing")
    }

    private func addStaticNodes(for method: RequestLine.Method, in route: String, handler: AnyResponseHandler? = nil) {
        let routes = ["/"] + route.components(separatedBy: "/")
        var hand: AnyResponseHandler
        if handler == nil {
            hand = self.handler
        } else {
            hand = handler!
        }

        handlerNotExists(for: method, in: route)
        assertNoThrow(try rootNode.addNode(routes: routes, method: method, handler: hand))
        assertThrowsError(try rootNode.addNode(routes: routes, method: method, handler: hand))
        handlerExists(for: method, in: route)
    }

    private func handlerExists(for method: RequestLine.Method, in route: String) {
        let routes = ["/"] + route.components(separatedBy: "/")
        assertNoThrow(try rootNode.findHandler(for: method, in: routes) != nil, "Handler does not exists for \(method.rawValue) \(route)")
    }
    private func handlerNotExists(for method: RequestLine.Method, in route: String) {
        let routes = ["/"] + route.components(separatedBy: "/")
        assertNil(try rootNode.findHandler(for: method, in: routes), "Handler does exists for \(method.rawValue) \(route)")
    }

    func testRouteThree() {
        let three = RouteTree()
        three.add(route: "/web/index", forMethod: .get, handler: handler)
        assertThrowsError(try three.findHandler(for: .get, in: "web"))
        acceptableError() {
            assertNoThrow(try three.findHandler(for: .get, in: "/web"))
        }
        assertNotNil(try three.findHandler(for: .get, in: "//web////index"))
        assertNotNil(try three.findHandler(for: .get, in: "/./web/.//./index"))
        assertNotNil(try three.findHandler(for: .get, in: "/web/asd/../index"))
        assertNotNil(try three.findHandler(for: .get, in: "/web/asd/.././index"))
        assertNil(try three.findHandler(for: .get, in: "/web/asd/../../../index"))
        assertNil(try three.findHandler(for: .get, in: "/.././web/asd/../../../index"))
        assertNil(try three.findHandler(for: .get, in: "/./web/asd/../.././../index"))

        three.add(route: "/", forMethod: .get, handler: handler)
        assertNotNil(try three.findHandler(for: .get, in: "/web/asd/../../../index"))
        assertNotNil(try three.findHandler(for: .get, in: "/web/../web/./asd//.///.././../../index"))

        XCTAssertEqual(three.allRoutes.count, 2)
        three.add(route: "/:dyn/asd", forMethod: .post, handler: handler)
        XCTAssertEqual(three.allRoutes.count, 3)
        three.add(route: "/:dyn/asd", forMethod: .get, handler: handler)
        XCTAssertEqual(three.allRoutes.count, 3)
        three.drop(method: .post, on: "/:dyn/asd")
        XCTAssertEqual(three.allRoutes.count, 3)
        three.drop(method: .get, on: "/:dyn/asd")
        XCTAssertEqual(three.allRoutes.count, 2)
    }

    func acceptableError(block: () throws -> ()) {
        #if TEST_ALL
            try! block()
        #endif
    }

    static var allTests = [
        ("testRootNode", testRootNode),
        ("testRouteThree", testRouteThree)
    ]
}

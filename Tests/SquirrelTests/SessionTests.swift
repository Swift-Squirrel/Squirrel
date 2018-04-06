//
//  SessionTests.swift
//  SquirrelTests
//
//  Created by Filip Klembara on 9/17/17.
//

import XCTest
@testable import Squirrel
import PathKit
import SquirrelJSON
import SquirrelConfig

class SessionTests: XCTestCase {

    var getRequest: Request {
        let content =  """
            GET /foo.php?first_name=John&last_name=Doe&action=Submit HTTP/1.1\r
            User-Agent: Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5 (.NET CLR 3.5.30729)\r
            Accept-Encoding: gzip\r\n\r\n
            """.data(using: .utf8)!
        return try! Request(remoteHostname: "127.0.0.1", data: content)
    }

    func testCreateSession() {
        let request = getRequest
        XCTAssertNoThrow(try request.newSession())
        
        XCTAssertTrue(request.sessionExists)
        XCTAssertNoThrow(try request.session())
        guard let session = try? request.session() else {
            XCTFail()
            return
        }

        XCTAssertTrue(session._isNew)
        XCTAssertFalse(session.shouldRemove)
        XCTAssert(session.expiry > Date(), "Expiry date must be future date")
    }

    func testRemoveSession() {
        let request = getRequest
        guard (try? request.newSession()) != nil else {
            XCTFail()
            return
        }
        guard let session = try? request.session() else {
            XCTFail()
            return
        }

        let path = squirrelConfig.session + "\(session.sessionID).session"

        XCTAssertTrue(path.exists)

        let res = session.delete()
        XCTAssertTrue(res)
        XCTAssertFalse(path.exists)
    }

    func testSessionInit() {
        let session = DefaultSession(id: "asdfghjkl", expiry: Date().addingTimeInterval(-40), remoteHostname: "127.0.0.1", userAgent: "Mozzila")
        XCTAssertEqual(session.sessionID, "asdfghjkl")
        XCTAssertEqual(session.userAgent, "Mozzila")
        XCTAssertFalse(session.expiry > Date())

        let session1 = DefaultSession(id: "asdfghjkl", remoteHostname: "127.0.0.1", userAgent: "Mozzila")
        XCTAssertNil(session1)

        let session2 = DefaultSession(id: "asdfasdf", expiry: Date().addingTimeInterval(60), remoteHostname: "127.0.0.1", userAgent: "Safari")
        XCTAssertEqual(session2.sessionID, "asdfasdf")
        XCTAssertEqual(session2.userAgent, "Safari")
        XCTAssertTrue(session2.expiry > Date())

        let session3 = DefaultSession(id: "asdfasdf", remoteHostname: "127.0.0.1", userAgent: "Safari")
        XCTAssertNotNil(session3)
        guard let session3a = session3 else {
            XCTFail()
            return
        }
        XCTAssertEqual(session3a.sessionID, "asdfasdf")
        XCTAssertEqual(session3a.userAgent, "Safari")
        XCTAssertTrue(session3a.expiry > Date())
    }

    func testSessionData() {
        let request = getRequest
        let session = try! request.newSession() as! DefaultSession

        session["username"] = "Tommy"

        guard let session1 = DefaultSession(id: session.sessionID, remoteHostname: "127.0.0.1", userAgent: "Mozilla/5.0 (Windows; U; Windows NT 6.1; en-US; rv:1.9.1.5) Gecko/20091102 Firefox/3.5.5 (.NET CLR 3.5.30729)") else {
            XCTFail()
            return
        }

        XCTAssertEqual(session.sessionID, session1.sessionID)
        XCTAssertEqual(session.count, 1)
        XCTAssertEqual(session1.count, 1)
        XCTAssertEqual(session, session1)
    }

    static let allTests = [
        ("testCreateSession", testCreateSession),
        ("testRemoveSession", testRemoveSession),
        ("testSessionInit", testSessionInit),
        ("testSessionData", testSessionData)
    ]

}

extension DefaultSession: Equatable {
    public static func ==(lhs: DefaultSession, rhs: DefaultSession) -> Bool {
        return lhs.data == rhs.data
    }
}

//
//  DBCredentials.swift
//  SquirrelConfig
//
//  Created by Filip Klembara on 8/23/17.
//

public struct DBCredentials: CustomStringConvertible {
    public struct UserCredentails {
        let username: String
        let password: String
    }
    public let user: UserCredentails?
    public let dbname: String
    public let host: String
    public let port: Int

    public var description: String {
        if let user = self.user {
            let pw = user.password.map({_ in return "*" })
            return "mongodb://\(user.username):\(pw)@\(host):\(port)/\(dbname)"
        }
        return "mongodb://\(host):\(port)/\(dbname)"
    }
}

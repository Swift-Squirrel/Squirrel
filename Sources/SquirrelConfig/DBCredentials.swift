//
//  DBCredentials.swift
//  SquirrelConfig
//
//  Created by Filip Klembara on 8/23/17.
//

struct DBCredentials: CustomStringConvertible {
    struct UserCredentails {
        let username: String
        let password: String
    }
    let user: UserCredentails?
    let dbname: String
    let host: String
    let port: Int

    var description: String {
        if let user = self.user {
            let pw = user.password.map({_ in return "*" })
            return "mongodb://\(user.username):\(pw)@\(host):\(port)/\(dbname)"
        }
        return "mongodb://\(host):\(port)/\(dbname)"
    }
}

//
//  DBCredentials.swift
//  SquirrelConfig
//
//  Created by Filip Klembara on 8/23/17.
//

/// Database credentials
public struct DBCredentials: CustomStringConvertible {
    /// User cedentials
    public struct UserCredentails {
        /// Username
        public let username: String
        /// Password
        public let password: String
    }
    /// User
    public let user: UserCredentails?
    /// Database name
    public let dbname: String
    /// Host
    public let host: String
    /// Port
    public let port: Int

    /// Description of connection
    public var description: String {
        if let user = self.user {
            let pw = user.password.map({_ in return "*" })
            return "mongodb://\(user.username):\(pw)@\(host):\(port)/\(dbname)"
        }
        return "mongodb://\(host):\(port)/\(dbname)"
    }
}

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

try server.run()

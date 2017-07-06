//
//  main.swift
//  micros
//
//  Created by Filip Klembara on 6/26/17.
//
//

import Foundation

Log.logging(on: true)
#if CONSOLE
Log.colored = false
#endif
let server = Server()

try server.run()

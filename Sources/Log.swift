//
//  Log.swift
//  Micros
//
//  Created by Eva Miloslava Výbohová on 28.6.17.
//
//

import Foundation

class Log {
    
    enum Logging {
        case off
        case on
    }
    
    enum LogGroups {
        case errors
        case warnings
        case info
        case all
    }
    
//    private static var logging = true
    
    static func logging(options: [LogGroups]) {
//        if(o))
//        Log.logging = on
    }
    
    static func write(message: String) {
//        if(Log.logging) {
//            print(message)
//        }
    }
    
    static func stderr(message: String) {
        
    }
}

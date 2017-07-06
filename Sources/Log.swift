//
//  Log.swift
//  Micros
//
//  Created by Eva Miloslava Výbohová on 28.6.17.
//
//

import Foundation
import Rainbow

class Log {
    
    enum LogGroups: UInt8 {
        case errors = 0b00000001
        case warnings = 0b00000010
        case info = 0b00000100
        case infoImportant = 0b00001000
        case infoAll = 0b00001100
        case debug = 0b00010000
    }
    
    enum Logging: UInt8 {
        case none = 0b0
        case all = 0b11111111
    }
    
    private static var logging: UInt8 = Logging.all.rawValue ^ LogGroups.debug.rawValue
    
    static func logging(options: [LogGroups]) {
        logging = 0
        for option in options {
            logging |= option.rawValue
        }
    }
    
    static func logging(on: Bool) {
        if on {
            logging = Logging.all.rawValue
        } else {
            logging = Logging.none.rawValue
        }
    }
    
    static func write(message: String, logGroup: LogGroups = .info) {
        var coloredMessage = message
        if (logGroup.rawValue & logging) != 0 {
            switch logGroup {
            case .debug:
                coloredMessage = coloredMessage.green
            case .errors:
                coloredMessage = coloredMessage.red
            case .info, .infoImportant, .infoAll:
                coloredMessage = coloredMessage.lightBlue
            case .warnings:
                coloredMessage = coloredMessage.lightYellow
            }
            print(coloredMessage)
        }
    }
    
    private init() {
        
    }
}

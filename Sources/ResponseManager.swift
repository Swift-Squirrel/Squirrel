//
//  ResponseManager.swift
//  Micros
//
//  Created by Filip Klembara on 6/27/17.
//
//

import Foundation

class ResponseManager {
    
    static var _singleton: ResponseManager? = nil
    
    static var manager: ResponseManager {
        if _singleton == nil {
            _singleton = ResponseManager()
        }
        return _singleton!
    }
    
    private init() {
        addRoutes()
    }
    
    static func findHandler(for request: Request) -> ((Request) -> Response)? {
        return nil
        return {
            (r: Request) in
            return Response()
        }
    }
}

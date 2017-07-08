//
//  DynamicRouteNode.swift
//  Micros
//
//  Created by Filip Klembara on 7/8/17.
//
//

import Cocoa

class DynamicRouteNode: RouteNode {
    override init(route: String) {
        var r = route
        r.remove(at: r.startIndex)
        
        super.init(route: r)
    }
    
    override func findHandler(for method: HTTPHeaders.Method, in routes: [String]) -> ResponseHandler? {
        if let res = super.findHandler(for: method, in: routes) {
            let key = route
            if key == "" {
                return res
            } else {
                let value = routes.first!
                return {
                    request in
                    request.setURLParameter(key: key, value: value)
                    return res(request)
                }
            }
        }
        return nil
    }
}

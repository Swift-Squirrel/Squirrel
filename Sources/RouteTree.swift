//
//  RouteTree.swift
//  Micros
//
//  Created by Filip Klembara on 7/2/17.
//
//

import Foundation

class RouteTree {
    private var root: RouteNode? = nil
    
    func add(route: String, forMethod method: HTTPHeaders.Method, handler: @escaping ResponseHandler) {
        Log.write(message: "Adding route for method \(method.rawValue) in route: \(route)", logGroup: .debug)
        
        if route == "/" {
            if root == nil {
                root = RouteNode(route: "/")
                do {
                   try root!.set(method: method, handler: handler)
                } catch let errr {
                    print(errr)
                }
            } else {
                do {
                    try root!.set(method: method, handler: handler)
                } catch let errr {
                    print(errr)
                }

            }
        } else {
            let routes = route.components(separatedBy: "/").filter { $0 != "" }
            if self.root == nil {
                self.root = RouteNode(route: "/")
            }
            
            let root = self.root!
            do {
                try root.addNode(routes: routes, method: method, handler: handler)
            } catch let errr {
                print(errr)
            }
        }
    }
    
    func findHandler(for method: HTTPHeaders.Method, in route: String) -> ResponseHandler? {
        guard route.hasPrefix("/") else {
            return nil
        }
        
        var routes = route.components(separatedBy: "/").filter { $0 != "" }
        
        routes.insert("/", at: 0)
        
        return root?.findHandler(for: method, in: routes)
    }

    
}

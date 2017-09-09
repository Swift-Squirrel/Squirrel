//
//  DynamicRouteNode.swift
//  Micros
//
//  Created by Filip Klembara on 7/8/17.
//
//

class DynamicRouteNode: RouteNode {
    override init(route: String) {
        var r = route
        r.remove(at: r.startIndex)

        super.init(route: r)
    }

    override func findHandler(for method: HTTPHeaders.Method, in routes: [String])
        throws -> AnyResponseHandler? {

        if let res = try super.findHandler(for: method, in: routes) {
            let key = route
            if key == "" {
                return res
            } else {
                let value = routes.first!
                return {
                    request in
                    request.setURLParameter(key: key, value: value)
                    return try res(request)
                }
            }
        }
        return nil
    }
}

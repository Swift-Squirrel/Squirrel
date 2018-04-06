//
//  URL+Params.swift
//  Micros
//
//  Created by Filip Klembara on 7/27/17.
//
//

import Foundation

extension URL {
    subscript(queryParam: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }

    var allQueryParams: [String: String?] {
        guard let url = URLComponents(string: self.absoluteString) else { return [:] }
        guard let items = url.queryItems else {return [:]}
        let val = items.flatMap({ [$0.name: $0.value]})
        var res: [String: String?] = [:]
        for (key, value) in val {
            res[key] = value
        }
        return res
    }
}

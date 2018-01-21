//
//  Path+normalized.swift
//  Squirrel
//
//  Created by Filip Klembara on 1/21/18.
//

import PathKit

extension Path {
    var httpNormalized: Path {
        var i = 0
        var results = [String]()
        results.reserveCapacity(components.count)
        for component in components {
            if component == ".." {
                guard i > 0 else {
                    return "/"
                }
                let _ = results.removeLast()
                i -= 1
            } else if component != "." {
                results.append(component)
                i += 1
            }
        }
        if i == components.count {
            return self
        } else {
            return Path(components: results)
        }
    }
}

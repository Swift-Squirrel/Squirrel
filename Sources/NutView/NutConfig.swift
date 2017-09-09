//
//  NutConfig.swift
//  NutView
//
//  Created by Filip Klembara on 9/6/17.
//

import PathKit

public struct NutConfig {
    private init() {}
    public static var fruits = Path().absolute() + "Fruits"

    public static var nuts = Path().absolute() + "Nuts"

    @discardableResult
    public static func clearFruits(removeRootDirectory: Bool = false) -> Bool {
        var res = (try? fruits.delete()) != nil
        if !removeRootDirectory {
            res = (try? fruits.mkdir()) != nil && res
        }
        return res
    }
}

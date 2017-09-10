//
//  NutConfig.swift
//  NutView
//
//  Created by Filip Klembara on 9/6/17.
//

import PathKit

/// Configuration class with *nut* and *fruit* directories
public struct NutConfig {
    private init() {}

    /// Directory with *.fruit* files
    public static var fruits = Path().absolute() + "Fruits"

    /// Directory with *.nut* files
    public static var nuts = Path().absolute() + "Nuts"

    /// Default date format
    public static var dateDefaultFormat = "MMM dd yyyy"

    /// Clears directory with *.fruit* files
    ///
    /// - Note: This will always remove root directory but if
    ///    `removeRootDirectory` is true, this will mkdir it again
    ///
    /// - Parameter removeRootDirectory: If true remove directory
    /// - Returns: true on success
    @discardableResult
    public static func clearFruits(removeRootDirectory: Bool = false) -> Bool {
        var res = (try? fruits.delete()) != nil
        if !removeRootDirectory {
            res = (try? fruits.mkdir()) != nil && res
        }
        return res
    }
}

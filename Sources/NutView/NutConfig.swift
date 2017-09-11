//
//  NutConfig.swift
//  NutView
//
//  Created by Filip Klembara on 9/6/17.
//

import PathKit
import Cache

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

    /// Fruit files caches
    public struct NutViewCache {

        /// Default name for cache
        public static let defaultName = "FruitsCache"

        static var cache: SpecializedCache<ViewToken> = SpecializedCache(name: defaultName)

        /// Set projection cache manager
        ///
        /// - Parameter specializedCache: Cache manager
        public static func setNutViewCache(name: String = defaultName, config: Config) {
            cache = SpecializedCache(name: name, config: config)
        }

        /// Total disk size
        public static var totalDiskSize: UInt64 {
            return (try? cache.totalDiskSize()) ?? 0
        }

        /// Name of cache
        public static var name: String {
            return cache.name
        }

        /// Path of cache directory
        public static var path: String {
            return cache.path
        }

        /// Clears the front and back cache storages.
        ///
        /// - Parameter keepRoot: Pass `true` to keep the existing disk cache directory
        /// after removing its contents. The default value is `false`.
        public static func clear(keepingRootDirectory keepRoot: Bool = false) {
            try? cache.clear(keepingRootDirectory: keepRoot)
        }

        /// Clears all expired objects from front and back storages.
        public static func clearExpired() {
            try? cache.clearExpired()
        }
    }
}

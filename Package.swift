// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Squirrel",
    targets: [
        Target(name: "App", dependencies: ["Squirrel"]),
        Target(name: "Squirrel", dependencies: ["SquirrelView", "SquirrelConfig", "SquirrelJSONEncoding"]),
        Target(name: "SquirrelView", dependencies: ["SquirrelJSONEncoding", "NutView"]),
        Target(name: "NutView", dependencies: ["SquirrelConfig", "SquirrelJSONEncoding"])
    ],
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/BlueSocket", majorVersion: 0, minor: 12),
        .Package(url: "https://github.com/sharplet/Regex.git", majorVersion: 1),
        .Package(url: "https://github.com/tris-foundation/reflection.git", majorVersion: 0),
        .Package(url: "https://github.com/LeoNavel/Evaluation.git", majorVersion: 0),
        .Package(url: "https://github.com/LeoNavel/MySqlSwiftNative.git", majorVersion: 1, minor: 3),
//        .Package(url: "https://github.com/tris-foundation/test.git", majorVersion: 0),
        .Package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git", majorVersion: 1),
        .Package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", majorVersion: 3, minor: 1),
        .Package(url: "https://github.com/LeoNavel/Squirrel-Connector.git", majorVersion: 0),
        .Package(url: "https://github.com/kylef/PathKit.git", majorVersion: 0)
    ]
)


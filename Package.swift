// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Squirrel",
    products: [
        .library(
            name: "Squirrel",
            targets: ["Squirrel"]),
        ],
    dependencies: [
        .package(url: "https://github.com/Swift-Squirrel/Squirrel-Connector.git",  from: "0.1.6"),
        .package(url: "https://github.com/kylef/PathKit.git",  from: "0.8.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git",  from: "1.4.1"),
        .package(url: "https://github.com/jpsim/Yams.git",  from: "0.3.6"),
        .package(url: "https://github.com/IBM-Swift/BlueSocket", from: "0.12.61"),
        .package(url: "https://github.com/antonmes/GZip.git", from: "5.0.0"),
        .package(url: "https://github.com/tris-foundation/test.git", from: "0.4.3"),
        .package(url: "https://github.com/Swift-Squirrel/SquirrelJSON.git", from: "0.1.0"),
        .package(url: "https://github.com/Swift-Squirrel/Squirrel-Core.git", from: "0.1.1"),
        .package(url: "https://github.com/Swift-Squirrel/NutView.git", from: "0.2.1")
        ],
    targets: [
        .target(
            name: "Squirrel",
            dependencies: ["NutView", "SquirrelConfig", "SquirrelJSON", "Socket", "GZip", "SquirrelCore"]),

        .target(
            name: "SquirrelConfig",
            dependencies: ["SquirrelConnector", "PathKit", "SwiftyBeaver", "NutView", "Yams"]),

        .testTarget(
            name: "SquirrelTests",
            dependencies: ["Squirrel", "Test"])
    ]
)

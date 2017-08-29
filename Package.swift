// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Squirrel",
    products: [
        .executable(
            name: "App",
            targets: ["App"]),
        .library(
            name: "Squirrel",
            targets: ["Squirrel"]),
        ],
    dependencies: [
        .package(url: "https://github.com/LeoNavel/Squirrel-Connector.git",  from: "0.1.1"),
        .package(url: "https://github.com/kylef/PathKit.git",  from: "0.8.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git",  from: "1.4.0"),
        .package(url: "https://github.com/behrang/YamlSwift.git",  from: "3.4.0"),
        .package(url: "https://github.com/LeoNavel/Evaluation.git",  from: "0.2.0"),
	.package(url: "https://github.com/IBM-Swift/SwiftyJSON.git", from: "15.0.1"),
        .package(url: "https://github.com/sharplet/Regex.git",  from: "1.1.0"),
        .package(url: "https://github.com/IBM-Swift/BlueSocket", from: "0.12.61"),
        .package(url: "https://github.com/tris-foundation/test.git", from: "0.4.3")
        ],
    targets: [
        .target(
            name: "App",
            dependencies: ["Squirrel"]),
        .target(
            name: "Squirrel",
            dependencies: ["SquirrelView", "SquirrelConfig", "SquirrelJSONEncoding", "Socket"]),
        .target(
            name: "SquirrelView",
            dependencies: ["SquirrelJSONEncoding", "NutView"]),
        .target(
                name: "NutView",
                dependencies: ["SquirrelConfig", "SquirrelJSONEncoding", "Evaluation", "SwiftyJSON", "Regex"]),

        .target(
            name: "SquirrelConfig",
            dependencies: ["SquirrelConnector", "PathKit", "SwiftyBeaver", "Yaml"]),
        .target(
            name: "SquirrelJSONEncoding",
            dependencies: ["SquirrelConnector"]),

        .testTarget(
            name: "SquirrelTests",
            dependencies: ["Squirrel", "Test"]),
        .testTarget(
            name: "NutViewTests",
            dependencies: ["NutView"]),
        ]
)

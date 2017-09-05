// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "Squirrel",
    products: [
        /*.executable(
            name: "App",
            targets: ["App"]),*/
        .library(
            name: "Squirrel",
            targets: ["Squirrel"]),
        ],
    dependencies: [
        .package(url: "https://github.com/LeoNavel/Squirrel-Connector.git",  from: "0.1.4"),
        .package(url: "https://github.com/kylef/PathKit.git",  from: "0.8.0"),
        .package(url: "https://github.com/SwiftyBeaver/SwiftyBeaver.git",  from: "1.4.0"),
        .package(url: "https://github.com/jpsim/Yams.git",  from: "0.3.5"),
        .package(url: "https://github.com/LeoNavel/Evaluation.git",  from: "0.2.0"),
        .package(url: "https://github.com/sharplet/Regex.git",  from: "1.1.0"),
        .package(url: "https://github.com/IBM-Swift/BlueSocket", from: "0.12.61"),
        .package(url: "https://github.com/tris-foundation/test.git", from: "0.4.3")
        ],
    targets: [
        /*.target(
            name: "App",
            dependencies: ["Squirrel"]),*/
        .target(
            name: "Squirrel",
            dependencies: ["SquirrelView", "SquirrelConfig", "SquirrelJSONEncoding", "Socket"]),
        .target(
            name: "SquirrelView",
            dependencies: ["SquirrelJSONEncoding", "NutView"]),
        .target(
                name: "NutView",
                dependencies: ["SquirrelConfig", "SquirrelJSONEncoding", "Evaluation", "Regex"]),

        .target(
            name: "SquirrelConfig",
            dependencies: ["SquirrelConnector", "PathKit", "SwiftyBeaver", "Yams"]),
        .target(
            name: "SquirrelJSONEncoding",
            dependencies: ["SquirrelConnector"]),

        .testTarget(
            name: "JSONCodingTests",
            dependencies: ["SquirrelJSONEncoding", "Test"]),
        .testTarget(
            name: "SquirrelTests",
            dependencies: ["Squirrel", "Test"])
        ]
)

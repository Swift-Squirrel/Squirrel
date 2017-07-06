// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "Micros",
    dependencies: [
        .Package(url: "https://github.com/IBM-Swift/BlueSocket", majorVersion: 0, minor: 12),
        .Package(url: "https://github.com/sharplet/Regex.git", majorVersion: 1),
        .Package(url: "https://github.com/onevcat/Rainbow", majorVersion: 2)
    ]
)

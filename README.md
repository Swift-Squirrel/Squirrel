[![CircleCI](https://img.shields.io/circleci/project/github/Swift-Squirrel/Squirrel.svg)](https://circleci.com/gh/Swift-Squirrel/Squirrel)
[![platform](https://img.shields.io/badge/Platforms-OS_X%20%7C_Linux-lightgray.svg?style=flat)](https://developer.apple.com/swift/)
[![SPM](https://img.shields.io/badge/spm-Compatible-brightgreen.svg)](https://swift.org)
[![swift](https://img.shields.io/badge/swift-4.1-orange.svg)](https://developer.apple.com/swift/)

# Swift Squirrel

**Swift Squirrel** is a simple open source web framework written in swift 4 aimed to help swift developers to create their custom APIs or web applications for Linux and Mac Os platform. 

- Open source
- Easy to learn
- Linux friendly
- Fast
- Supports MongoDB

Check out our [docs page](https://squirel.codes)!

## Installing

Add **Swift Squirrel** as dependency in your *Package.swift*

```swift
// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "Your app",
    products: [
        // Your products
    ],
    dependencies: [
        .package(url: "https://github.com/Swift-Squirrel/Squirrel.git", from: "1.0.0"),
        // Other dependencies
    ],
    targets: [
        .target(
            name: "Your Target",
            dependencies: [..., "Squirrel"]),
    ]
)
```

And in source add import line

```swift
import Squirrel
```

## Usage

The most simple usage is this Hello, World!

```swift
import Squirrel

let server = Server()

server.get("/") {
    return "Hello, World!"
}

server.run()
```

## Documentation    
For more informations check out [documentation](https://squirrel.codes)

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## Authors

* **Filip Klembara** - *Creator* - [github](https://github.com/LeoNavel)

See also CONTRIBUTORS to list of contributors who participated in this project.

## License

This project is licensed under the Apache License Version 2.0 - see the LICENSE file for details


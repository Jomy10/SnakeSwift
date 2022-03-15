// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnakeMacApp",
	platforms: [.macOS(.v12)],
    dependencies: [
        .package(name: "SnakeSwiftCore", path: "../SnakeSwiftCore")
    ],
    targets: [
        .executableTarget(
            name: "SnakeMacApp",
            dependencies: [
                "SnakeSwiftCore"
            ],
            resources: [

            ]
        ),
    ]
)

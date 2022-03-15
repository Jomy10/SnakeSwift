// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SnakeSwiftCore",
    platforms: [.macOS(.v11)],
    products: [
        .library(
            name: "SnakeSwiftCore",
            targets: ["SnakeSwiftCore"]),
    ],
    dependencies: [
        .package(name: "Tokamak", url: "https://github.com/Jomy10/Tokamak", from: "0.9.2")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SnakeSwiftCore",
            dependencies: [
                .product(name: "TokamakDOM", package: "Tokamak")
            ]),
        .testTarget(
            name: "SnakeSwiftCoreTests",
            dependencies: ["SnakeSwiftCore"]),
    ]
)

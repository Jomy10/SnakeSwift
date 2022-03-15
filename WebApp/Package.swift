// swift-tools-version:5.5
import PackageDescription
let package = Package(
    name: "WebApp",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "WebApp", targets: ["WebApp"])
    ],
    dependencies: [
        .package(name: "Tokamak", url: "https://github.com/Jomy10/Tokamak", from: "0.9.2"),
        .package(name: "SnakeSwiftCore", path: "../SnakeSwiftCore"),
    ],
    targets: [
        .target(
            name: "WebApp",
            dependencies: [
                .product(name: "TokamakDOM", package: "Tokamak"),
                .product(name: "SnakeSwiftCore", package: "SnakeSwiftCore")
            ]),
	]
)

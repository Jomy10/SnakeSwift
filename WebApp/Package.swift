// swift-tools-version:5.3
import PackageDescription
let package = Package(
    name: "WebApp",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "WebApp", targets: ["WebApp"])
    ],
    dependencies: [
        .package(name: "Tokamak", url: "https://github.com/Jomy10/Tokamak", from: "0.9.2")
    ],
    targets: [
        .target(
            name: "WebApp",
            dependencies: [
                .product(name: "TokamakDOM", package: "Tokamak")
            ]),
	]
)

// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MainApp",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MainApp",
            targets: ["MainApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.10.1"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.3"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.2"),
        .package(url: "https://github.com/apple/swift-collections", from: "1.1.4")
    ],
    targets: [
        .target(
            name: "MainApp",
            dependencies: [
                "Alamofire",
                "Moya",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Collections", package: "swift-collections"),
                "Feature"
            ]),
        .target(
            name: "Feature",
            dependencies: [
                "Alamofire",
                "Moya",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "Collections", package: "swift-collections")
            ],
            path: "Sources/Feature"),
        .testTarget(
            name: "MainAppTests",
            dependencies: ["MainApp"]),
    ]
)

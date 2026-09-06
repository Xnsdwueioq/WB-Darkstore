// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkPackage",
    platforms: [
        .iOS(.v18),
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NetworkPackage",
            targets: ["NetworkPackage"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/realm/SwiftLint",
            from: "0.65.1"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-generator",
            from: "1.13.1"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime",
            from: "1.12.0"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-urlsession",
            from: "1.3.0"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "NetworkPackage",
            dependencies: [
                .product(
                    name: "OpenAPIRuntime",
                    package: "swift-openapi-runtime"
                ),
                .product(
                    name: "OpenAPIURLSession",
                    package: "swift-openapi-urlsession"
                ),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
            plugins: [
                .plugin(
                    name: "OpenAPIGenerator",
                    package: "swift-openapi-generator"
                ),
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                ),
            ]
        ),
        .testTarget(
            name: "NetworkPackageTests",
            dependencies: ["NetworkPackage"],
            swiftSettings: [
                .enableUpcomingFeature("ApproachableConcurrency"),
            ],
            plugins: [
                .plugin(
                    name: "SwiftLintBuildToolPlugin",
                    package: "SwiftLint"
                ),
            ],
        ),
    ]
)

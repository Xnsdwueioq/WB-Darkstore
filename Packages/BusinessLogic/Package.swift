// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BusinessLogic",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BusinessLogic",
            targets: ["BusinessLogic"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/realm/SwiftLint",
            from: "0.65.1"
        ),
        .package(
            name: "NetworkPackage",
            path: "../NetworkPackage"
        ),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BusinessLogic",
            dependencies: [
                .product(
                    name: "NetworkPackage",
                    package: "NetworkPackage"
                ),
            ],
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
        .testTarget(
            name: "BusinessLogicTests",
            dependencies: [
                "BusinessLogic",
                .product(
                    name: "NetworkPackage",
                    package: "NetworkPackage"
                ),
            ],
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

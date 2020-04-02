// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Mutexes",
    platforms: [
        .iOS(.v12), .macOS(.v10_14), .tvOS(.v12), .watchOS(.v5)
    ],
    products: [
        .library(
            name: "Mutexes",
            targets: ["Mutexes"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SergeBouts/XConcurrencyKit.git", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "Mutexes",
            dependencies: []),
        .testTarget(
            name: "MutexesTests",
            dependencies: ["Mutexes", "XConcurrencyKit"]),
    ]
)

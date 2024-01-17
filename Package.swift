// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Artera1_AWARE",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Artera1_AWARE",
            targets: ["Artera1_AWARE"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Artera1_AWARE"),
        .testTarget(
            name: "Artera1_AWARETests",
            dependencies: ["Artera1_AWARE", .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.8.1"))]),
    ]
)

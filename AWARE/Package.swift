// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AWARE",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AWARE",
            targets: ["AWARE"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.5.4"),
        .package(url: "https://github.com/firebase/firebase-database-swift.git", from: "10.0.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.0.0"),
        .package(url: "https://github.com/firebase/firebase-analytics-swift.git", from: "8.0.0"),
        .package(url: "https://github.com/firebase/firebase-auth.git", from: "8.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "AWARE",
            dependencies: ["Alamofire", "FirebaseDatabase", "FirebaseAnalytics", "FirebaseAnalyticsSwift", "FirebaseAuth"]),
        .testTarget(
            name: "AWARETests",
            dependencies: ["AWARE"]),
    ]
)

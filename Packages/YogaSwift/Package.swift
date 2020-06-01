// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YogaSwift",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "YogaSwift", 
            targets: ["YogaSwift"]
        )
    ],
    dependencies: [
        .package(path: "../Yoga"),
    ],
    targets: [
        .target(
            name: "YogaSwift",
            dependencies: ["Yoga"],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [
        .version("5")
    ]
)
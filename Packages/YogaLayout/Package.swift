// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YogaLayout",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(
            name: "YogaLayout", 
            targets: ["YogaLayout"]
        )
    ],
    dependencies: [
        .package(path: "../YogaSwift"),
    ],
    targets: [
        .target(
            name: "YogaLayout",
            dependencies: ["YogaSwift"],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [
        .version("5")
    ]
)
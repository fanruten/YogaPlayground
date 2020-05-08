// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PlaygroundShim",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "PlaygroundShim", 
            type: .static,
            targets: ["PlaygroundShim"]
        )
    ],
    dependencies: [
        .package(path: "../YogaLayout"),
        .package(path: "../TableController"),
        .package(path: "../TableModelBuilder")        
    ],
    targets: [
        .target(
            name: "PlaygroundShim",
            dependencies: ["YogaLayout", "TableController", "TableModelBuilder"],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [
        .version("5")
    ]
)

// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "UIComponents", 
            type: .dynamic,
            targets: ["UIComponents"]
        )
    ],
    dependencies: [
        .package(path: "YogaLayout"),
        .package(path: "TableController")
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: ["YogaLayout", "TableController"],
            path: "Sources"
        )
    ],
    swiftLanguageVersions: [
        .version("5")
    ]
)

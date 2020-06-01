// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YogaPlayground",
    platforms: [
        .iOS(.v8)
    ],
    products: [
        .library(name: "YogaPlayground", targets: ["YogaPlayground"]),
        .library(name: "YogaSwift", targets: ["YogaSwift"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "Yoga"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "YogaPlayground",
            dependencies: [],
            path: "Sources/YogaPlayground"),
        .target(
            name: "YogaSwift",
            dependencies: ["Yoga"],
            path: "Sources/YogaSwift"),        
        .testTarget(
            name: "YogaPlaygroundTests",
            dependencies: ["YogaPlayground"]),
    ],
    swiftLanguageVersions: [.v5]
)
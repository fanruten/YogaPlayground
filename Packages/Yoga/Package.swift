// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Yoga",
    platforms: [
        .macOS(.v10_10),
        .iOS(.v8),
        .tvOS(.v9),
        .watchOS(.v2)
    ],
    products: [
        .library(
            name: "Yoga", 
            type: .static,
            targets: ["Yoga"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Yoga",
            path: "Sources",
            exclude: [],
            sources: ["lib/yoga"],
            publicHeadersPath: "Public",
            cSettings: [ 
                .headerSearchPath("./")
            ]
        )
    ],
    swiftLanguageVersions: [
        .version("5")
    ],
    cLanguageStandard: .gnu11,
    cxxLanguageStandard: .gnucxx14
)
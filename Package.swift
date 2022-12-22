// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Settings",
    platforms: [
        .watchOS(.v4),
        .iOS(.v13),
        .tvOS(.v13),
        .macOS(.v10_15)
      ],
    products: [
        .library(
            name: "Settings",
            targets: ["Objective-C", "Settings"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Objective-C",
            path: "Sources/ObjC"
        ),
        .target(
            name: "Settings",
            dependencies: ["Objective-C"],
            path: "Sources/Swift"
        )
    ]
)

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
            targets: ["Entitlement", "Settings"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Entitlement",
            path: "Sources/ObjC/Entitlement"
        ),
        .target(
            name: "Settings",
            dependencies: ["Entitlement"],
            path: "Sources/Swift"
        )
    ]
)

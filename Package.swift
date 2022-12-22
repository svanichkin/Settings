// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Settings",
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

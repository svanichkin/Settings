// swift-tools-version:5.7

import PackageDescription

let package = Package(
    name: "Settings",
    products: [
        .library(
            name: "Settings",
            targets: ["SettingsObjC", "SettingsSwift"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SettingsObjC",
            path: "Sources/ObjC"
        ),
        .target(
            name: "SettingsSwift",
            dependencies: ["SettingsObjC"],
            path: "Sources/Swift"
        )
    ]
)

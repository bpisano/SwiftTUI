// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AttributeGraph",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "AttributeGraph",
            targets: ["AttributeGraph", "SwiftTUI"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftTUI",
            dependencies: ["AttributeGraph"],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(
            name: "AttributeGraph",
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .testTarget(
            name: "AttributeGraphTests",
            dependencies: ["AttributeGraph"]
        ),
    ]
)

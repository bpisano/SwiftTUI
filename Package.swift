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
            targets: ["AttributeGraph", "Terminal", "_SwiftTUI", "Test", "SwiftTUI"]
        ),
    ],
    dependencies: [
        .package(path: "../Geometry"),
    ],
    targets: [
        .target(
            name: "Terminal",
            dependencies: ["Geometry"],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(
            name: "_SwiftTUI",
            dependencies: ["AttributeGraph"],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(
            name: "SwiftTUI",
            dependencies: [
                "Geometry",
                "AttributeGraph",
                "Terminal"
            ],
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
        .target(
            name: "Test",
            dependencies: ["AttributeGraph"],
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

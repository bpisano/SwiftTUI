// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AttributeGraph",
    platforms: [
        .macOS(.v26),
        .iOS(.v26)
    ],
    products: [
        .library(
            name: "AttributeGraph",
            targets: ["AttributeGraph", "Terminal", "SwiftTUI"]
        )
    ],
    dependencies: [
        .package(path: "~/Dev/Packages/Geometry")
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
            name: "SwiftTUI",
            dependencies: [
                "Geometry",
                "AttributeGraph",
                "Terminal",
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
        .testTarget(
            name: "DebugTests",
            dependencies: [
                "Geometry",
                "AttributeGraph",
                "SwiftTUI",
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        )
    ]
)

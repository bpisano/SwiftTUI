// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SwiftTUI",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(
            name: "SwiftTUI",
            targets: ["SwiftTUI"]
        )
    ],
    targets: [
        .target(
            name: "AttributeGraph",
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(
            name: "AttributeGraph2",
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(name: "Geometry"),
        .target(
            name: "Terminal",
            dependencies: ["Geometry"],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .target(
            name: "SwiftTUICore",
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
            name: "SwiftTUI",
            dependencies: [
                "Terminal",
                "SwiftTUICore",
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .executableTarget(
            name: "AppDemo",
            dependencies: ["SwiftTUI"]
        ),
        .testTarget(
            name: "AttributeGraphTests",
            dependencies: ["AttributeGraph"]
        ),
        .testTarget(
            name: "AttributeGraph2Tests",
            dependencies: ["AttributeGraph2"],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        ),
        .testTarget(
            name: "GeometryTests",
            dependencies: ["Geometry"]
        ),
        .testTarget(
            name: "SwiftTUICoreTests",
            dependencies: [
                "Geometry",
                "AttributeGraph",
                "SwiftTUICore",
                "SwiftTUI",
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        )
    ]
)

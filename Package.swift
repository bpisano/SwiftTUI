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
                "AttributeGraph"
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
            name: "GeometryTests",
            dependencies: ["Geometry"]
        ),
        .testTarget(
            name: "SwiftTUICoreTests",
            dependencies: [
                "Geometry",
                "AttributeGraph",
                "SwiftTUICore",
            ],
            swiftSettings: [
                .defaultIsolation(MainActor.self)
            ]
        )
    ]
)

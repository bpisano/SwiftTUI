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
        ),
        .target(name: "Geometry"),
        .target(
            name: "Terminal",
            dependencies: ["Geometry"]
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
                "SwiftTUI",
            ]
        )
    ]
)

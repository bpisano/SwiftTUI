// swift-tools-version: 6.3

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
        ),
        .library(
            name: "SwiftTUIRuntime",
            targets: ["SwiftTUIRuntime"]
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
            ]
        ),
        .target(
            name: "SwiftTUIRuntime",
            dependencies: [
                "Geometry",
                "AttributeGraph",
                "Terminal",
                "SwiftTUICore",
            ]
        ),
        .target(
            name: "SwiftTUI",
            dependencies: [
                "Terminal",
                "SwiftTUICore",
                "SwiftTUIRuntime",
            ],
        ),
        .executableTarget(
            name: "AppDemo",
            dependencies: ["SwiftTUI"]
        ),
        .testTarget(
            name: "AttributeGraphTests",
            dependencies: ["AttributeGraph"],
            swiftSettings: [.defaultIsolation(MainActor.self)]
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
                "Terminal",
                "SwiftTUICore",
                "SwiftTUI",
                "SwiftTUIRuntime",
            ],
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)

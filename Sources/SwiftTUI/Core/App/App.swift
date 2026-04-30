//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation

@_exported import SwiftTUICore
@_exported import Geometry
@_exported import Terminal
@_exported import SwiftTUIRuntime

@MainActor
public protocol App {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }

    init()
}

extension App {
    public nonisolated static func main() {
        SwiftTUIRuntime.main {
            let app: Self = .init()
            app.body
        }
    }
}

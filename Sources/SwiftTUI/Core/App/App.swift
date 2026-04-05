//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import AttributeGraph
import Terminal

@_exported import SwiftTUICore
@_exported import Geometry

@MainActor
public protocol App {
    associatedtype Body: View

    @ViewBuilder
    var body: Body { get }

    init()
}

extension App {
    public static func main() {
        let app: Self = .init()
        nonisolated(unsafe) let view: Body = app.body

        let terminal: Terminal = .current
        let renderState: RenderState = .init()
        let engine: TerminalEngine = .init(
            configuration: .standard,
            terminal: terminal,
            view: RootLayout {
                view
            }
        )

        let graph: Graph = .init()
        graph.makeCurrent()
        graph.onInvalidate = {
            renderState.setNeedsRender()
        }

        engine.setup()

        let frameRate: Double = 1 / 60
        let timer = Timer.scheduledTimer(
            withTimeInterval: frameRate,
            repeats: true
        ) { _ in
            Task { @MainActor in
                guard renderState.needsRender else { return }
                renderState.clearNeedsRender()
                await engine.render()
            }
        }

        RunLoop.main.add(timer, forMode: .common)
        RunLoop.main.run()
    }
}

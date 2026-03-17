//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import AttributeGraph
import Foundation
import SwiftTUICore
import Terminal

public protocol App: Sendable {
    associatedtype Body: View

    var body: Body { get }

    init()
}

extension App {
    public static func main() {
        let app: Self = .init()
        let view: Body = app.body

        let terminal: Terminal = .current
        let renderer: TerminalRenderer = .init(
            terminal: terminal,
            view: RootLayout {
                view
            }
        )
        let frameRate: Double = 1 / 60

        var needsRender: Bool = true

        let graph: Graph = .init()
        graph.makeCurrent()
        graph.onInvalidate = {
            needsRender = true
        }

        renderer.setup()

        let timer = Timer.scheduledTimer(
            withTimeInterval: frameRate,
            repeats: true
        ) { _ in
            Task { @MainActor in
                guard needsRender else { return }
                needsRender = false
                renderer.prepareForRender()
                renderer.render()
            }
        }

        RunLoop.main.add(timer, forMode: .common)
        RunLoop.main.run()
    }
}

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

public struct App<V: View>: Sendable {
    private let terminal: Terminal = .current
    private let renderer: TerminalRenderer<RootView<V>>
    private let view: V
    private let frameRate: Double

    public init(
        frameRate: Double = 1 / 60,
        @ViewBuilder _ content: () -> V
    ) {
        self.view = content()
        self.frameRate = frameRate
        self.renderer = .init(
            terminal: terminal,
            view: RootView(view)
        )
    }

    public func run() {
        var needsRender: Bool = false

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
                self.renderer.prepareForRender()
                self.renderer.render()
                needsRender = false
            }
        }

        RunLoop.main.add(timer, forMode: .common)
        RunLoop.main.run()
    }
}

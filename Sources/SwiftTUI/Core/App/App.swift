//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import Terminal
import SwiftTUICore

public struct App<V: View>: Sendable {
    private let terminal: Terminal = .current
    private let renderer: TerminalRenderer
    private let view: V

    public init(@ViewBuilder _ content: () -> V) {
        self.view = content()
        self.renderer = .init(terminal: terminal)
    }

    public func run() {
        renderer.render(
            RootView {
                view
            }
        )

        terminal.cursor.move(to: .zero)
        for (index, line) in renderer.buffer.render().enumerated() {
            terminal.cursor.writeBuffered(line)
            if index < Int(renderer.buffer.size.height) - 1 {
                terminal.cursor.writeBuffered("\n")
            }
        }

        terminal.cursor.move(to: .zero)
        terminal.cursor.flush()

        RunLoop.main.run()
    }
}

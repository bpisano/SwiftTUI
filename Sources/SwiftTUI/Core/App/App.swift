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
        terminal.cursor.clearScreen()
        renderer.render(view)

        var y: Double = 0
        for line in renderer.buffer.render() {
            terminal.cursor.move(to: .init(x: 0, y: y))
            terminal.cursor.writeBuffered(line)
            y += 1
        }

        terminal.cursor.flush()
    }
}

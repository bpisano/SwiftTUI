//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import AttributeGraph
import Geometry
import Terminal
import SwiftTUICore

final class TerminalRenderer {
    private(set) var buffer: TerminalBuffer

    init(terminal: Terminal) {
        self.buffer = .init(size: terminal.screen.size)
    }

    func render<V: View>(_ view: V) {
        @Attribute var screenOrigin: Point = .zero
        @Attribute var screenSize: Size = self.buffer.size
        @Attribute var view: V = view

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize
        )
        let outputs: ViewOutputs = V.makeView($view, inputs: inputs)

        render(displayList: outputs.displayList.wrappedValue)
    }

    private func render(displayList: DisplayList) {
        for item in displayList.items {
            switch item.content {
            case .empty:
                continue
            case .command(let drawCommand):
                renderCommand(drawCommand, at: item.frame.origin)
            case .childList(let displayList):
                render(displayList: displayList)
            }
        }
    }

    private func renderCommand(_ command: DrawCommand, at origin: Point) {
        switch command {
        case .putLine(let line):
            buffer.putLine(line, at: origin)
        }
    }
}

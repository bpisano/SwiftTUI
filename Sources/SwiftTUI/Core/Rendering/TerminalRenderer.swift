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

final class TerminalRenderer<V: View> {
    private(set) var buffer: TerminalBuffer

    private let terminal: Terminal
    private var outputs: ViewOutputs?

    @Attribute private var screenOrigin: Point = .zero
    @Attribute private var screenSize: Size
    @Attribute private var viewPhase: ViewPhase = .inactive
    @Attribute private var view: V

    init(
        terminal: Terminal,
        view: V
    ) {
        self.terminal = terminal
        self.buffer = .init(size: terminal.screen.size)
        self._screenSize = .init(wrappedValue: terminal.screen.size)
        self._view = .init(wrappedValue: view)
    }

    func setup() {
        terminal.cursor.clearScreen()
        terminal.enableRawMode()
        terminal.onExit = { [weak self] in
            guard let self else { return }
            self.terminal.disableRawMode()
            exit(0)
        }

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase
        )
        outputs = V.makeView($view, inputs: inputs)

        prepareForRender()
        render()

        viewPhase = .active

        prepareForRender()
        render()
    }

    func prepareForRender() {
        guard let outputs else {
            assertionFailure("Outputs not set up. Call setup() before rendering.")
            return
        }
        fillBuffer(with: outputs.displayList.wrappedValue, at: .zero)
    }

    func render() {
        let stringBuffer: String = buffer.stringValue()
        terminal.cursor.move(to: .zero)
        terminal.cursor.write(stringBuffer)

        CallbackQueue.shared.executeAll()
    }

    private func fillBuffer(with displayList: DisplayList, at origin: Point) {
        for item in displayList.items {
            switch item.content {
            case .empty:
                continue
            case .command(let drawCommand):
                fillBufferCell(with: drawCommand, at: origin)
            case .childList(let wrappedDisplayList):
                fillBuffer(with: wrappedDisplayList, at: origin + item.frame.origin)
            }
        }
    }

    private func fillBufferCell(with command: DrawCommand, at origin: Point) {
        switch command {
        case .putLine(let line):
            buffer.putLine(line, at: origin)
        }
    }
}

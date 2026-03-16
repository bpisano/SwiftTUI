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
    @Attribute private var viewPhase: ViewPhase = .active
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
        terminal.screen.onSizeChange = { [weak self] screenSize in
            guard let self else { return }
            self.buffer = TerminalBuffer(size: screenSize)
            self.screenSize = screenSize
        }
        terminal.onExit = { [weak self] in
            guard let self else { return }
            self.terminal.disableRawMode()
            exit(0)
        }

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            storage: .init()
        )
        outputs = V.makeView($view, inputs: inputs)
    }

    func prepareForRender() {
        guard let outputs else {
            assertionFailure("Outputs not set up. Call setup() before rendering.")
            return
        }
        fillBuffer(with: outputs.displayList.wrappedValue)
    }

    func render() {
        let stringFrame: String = buffer.makeStringFrame()

        terminal.cursor.move(to: .zero)
        terminal.cursor.write(stringFrame)

        CallbackQueue.shared.executeAll()
    }

    private func fillBuffer(with displayList: DisplayList) {
        for item in displayList.items {
            switch item {
            case let .childList(wrappedDisplayList):
                fillBuffer(with: wrappedDisplayList)
            case let .command(command):
                fillBufferCell(with: command)
            }
        }
    }

    private func fillBufferCell(with command: DisplayList.Command) {
        switch command.action {
        case let .putLine(line):
            buffer.putLine(line, at: command.frame.origin)
        }
    }
}

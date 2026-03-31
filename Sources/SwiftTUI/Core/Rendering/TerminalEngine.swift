//
//  TerminalEngine.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 17/03/2026.
//

import Foundation
import Geometry
import AttributeGraph
import Terminal
import SwiftTUICore

final class TerminalEngine<V: View> {
    private let terminal: Terminal
    private let renderer: TerminalRenderer
    private var outputs: ViewOutputs?

    @Attribute private var screenOrigin: Point = .zero
    @Attribute private var screenSize: Size
    @Attribute private var viewPhase: ViewPhase = .active
    @Attribute private var view: V

    init(
        configuration: RenderingConfiguration,
        terminal: Terminal,
        view: V
    ) {
        self.renderer = .init(configuration: configuration)
        self.terminal = terminal
        self._screenSize = .init(wrappedValue: terminal.screen.size)
        self._view = .init(wrappedValue: view)
    }

    func setup() {
        terminal.cursor.clearScreen()
        terminal.enableRawMode()
        terminal.cursor.hide()
        terminal.screen.onSizeChange = { [weak self] screenSize in
            guard let self else { return }
            self.screenSize = screenSize
        }
        terminal.onExit = { [weak self] in
            guard let self else { return }
            self.terminal.disableRawMode()
            self.terminal.cursor.show()
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

    func render() {
        guard let outputs else {
            assertionFailure("Outputs not set up. Call setup() before rendering.")
            return
        }

        let stringFrame: String = renderer.renderFrame(
            displayList: outputs.displayList.wrappedValue,
            in: screenSize
        )

        terminal.cursor.move(to: .zero)
        terminal.cursor.write(stringFrame)

        CallbackQueue.shared.executeAll()
    }
}

extension RenderingConfiguration {
    static let standard: Self = .init(
        emptyChar: " ",
        lineJoinSeparator: "",
        renderColor: true
    )
}

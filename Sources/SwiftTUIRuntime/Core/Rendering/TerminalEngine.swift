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

@MainActor
final class TerminalEngine<V: View> {
    private let terminal: Terminal
    private let renderer: TerminalRenderer
    private let focusManager: FocusManager
    private let focusRouter: FocusKeyboardRouter
    private var outputs: ViewOutputs?
    private var exitInputTask: Task<Void, Never>?
    private var lastFocusList: FocusList?

    @Attribute private var screenOrigin: Point = .zero
    @Attribute private var screenSize: Size
    @Attribute private var viewPhase: ViewPhase = .active
    @Attribute private var environment: EnvironmentValues = .init()
    @Attribute private var view: V

    init(
        configuration: RenderingConfiguration,
        terminal: Terminal,
        view: V
    ) {
        self.renderer = .init(configuration: configuration)
        self.terminal = terminal

        let manager: FocusManager = .init()
        self.focusManager = manager
        self.focusRouter = .init(manager: manager)

        self._screenSize = .init(wrappedValue: terminal.screen.size)
        self._view = .init(wrappedValue: view)

        var initialEnvironment: EnvironmentValues = .init()
        initialEnvironment.focusManager = manager
        self._environment = .init(wrappedValue: initialEnvironment)
    }

    func setup() {
        terminal.cursor.clearScreen()
        terminal.enableRawMode()
        terminal.enableKeyboardEventReporting()
        terminal.cursor.hide()
        // Capture the runtime Graph so signal-driven mutations (resize) and
        // exit callbacks still notify the right `onInvalidate`.
        let graph: Graph = .current
        terminal.screen.onSizeChange = { [weak self] screenSize in
            guard let self else { return }
            Graph.withCurrent(graph) {
                self.screenSize = screenSize
            }
        }
        terminal.onExit = { [weak self] in
            guard let self else { return }
            self.shutdownAndExit()
        }
        startExitInputWatcher()
        focusRouter.start()

        let inputs: ViewInputs = .init(
            position: $screenOrigin,
            size: $screenSize,
            phase: $viewPhase,
            environment: $environment,
            storage: .init()
        )
        outputs = V.makeView($view, inputs: inputs)
    }

    func render() async {
        guard let outputs else {
            assertionFailure("Outputs not set up. Call setup() before rendering.")
            return
        }

        // Snapshot Sendable values on MainActor before crossing the actor boundary.
        // wrappedValue reads must happen here — this is where the graph lives.
        let displayList = outputs.displayList.wrappedValue
        let size = screenSize

        if let focusListAttribute = outputs.focusList {
            let focusList = focusListAttribute.wrappedValue
            if focusList != lastFocusList {
                lastFocusList = focusList
                focusManager.rebuild(from: focusList)
            }
        }

        // Buffer fill and string construction run on the renderer actor's executor,
        // freeing MainActor to process input events and state updates in the meantime.
        let frame = await renderer.renderFrame(displayList: displayList, in: size)

        // Back on MainActor: write to the terminal (fast syscall) and flush callbacks.
        terminal.cursor.move(to: .zero)
        terminal.cursor.write(frame)

        CallbackQueue.shared.executeAll()
    }

    private func startExitInputWatcher() {
        exitInputTask?.cancel()
        exitInputTask = Task { [weak self] in
            let events = await Keyboard.current.events()

            for await event in events {
                guard event.isPressed else { continue }
                guard event.key == .character("c") else { continue }
                guard event.modifiers.contains(.control) else { continue }

                self?.shutdownAndExit()
                break
            }
        }
    }

    private func shutdownAndExit() {
        exitInputTask?.cancel()
        focusRouter.stop()
        terminal.disableKeyboardEventReporting()
        terminal.disableRawMode()
        terminal.cursor.show()
        exit(0)
    }
}


//
//  FocusKeyboardRouter.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph
import Terminal

@MainActor
@_documentation(visibility: internal)
public final class FocusKeyboardRouter {
    private let manager: FocusManager
    private let keyboard: Keyboard
    private var subscription: InputSubscription?

    public init(
        manager: FocusManager,
        keyboard: Keyboard = .current
    ) {
        self.manager = manager
        self.keyboard = keyboard
    }

    public func start() {
        subscription?.cancel()
        // Capture the runtime Graph so that handler-driven attribute writes
        // notify the right `onInvalidate`, even though dispatch hops through
        // a detached background task and would otherwise see the default graph.
        let graph: Graph = .current
        subscription = keyboard.subscribe(priority: .system) { [weak self] event in
            Graph.withCurrent(graph) {
                self?.handle(event)
            }
        }
    }

    public func stop() {
        subscription?.cancel()
        subscription = nil
    }

    func handle(_ event: Keyboard.Event) {
        guard !event.isConsumed else { return }
        guard event.isPressed else { return }

        // The focused view gets first dibs on the key (e.g. a Button consuming
        // Return). Only if it leaves the event unconsumed do we treat it as
        // focus navigation.
        manager.dispatchKeyToFocused(event)
        guard !event.isConsumed else { return }

        guard let move = focusMove(for: event) else { return }
        execute(move)
    }

    private func execute(_ move: Move) {
        switch move {
        case .spatial(let direction):
            manager.move(direction)
        case .tab(let direction):
            manager.move(direction)
        }
    }

    private func focusMove(for event: Keyboard.Event) -> Move? {
        switch (event.key, event.modifiers) {
        case (.tab, let mods) where mods.contains(.shift):
            return .tab(.previous)
        case (.tab, _):
            return .tab(.next)
        case (.arrowUp, _):
            return .spatial(.up)
        case (.arrowDown, _):
            return .spatial(.down)
        case (.arrowLeft, _):
            return .spatial(.left)
        case (.arrowRight, _):
            return .spatial(.right)
        default:
            return nil
        }
    }
}

extension FocusKeyboardRouter {
    private enum Move {
        case spatial(FocusMap.Direction)
        case tab(FocusMap.TabDirection)
    }
}

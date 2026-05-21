//
//  FocusKeyboardRouter.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Terminal

@MainActor
public final class FocusKeyboardRouter {
    private let manager: FocusManager
    private let keyboard: Keyboard
    private var task: Task<Void, Never>?

    public init(
        manager: FocusManager,
        keyboard: Keyboard = .current
    ) {
        self.manager = manager
        self.keyboard = keyboard
    }

    public func start() {
        task?.cancel()
        task = Task { [weak self] in
            let events = await self?.keyboard.events()
            guard let events else { return }

            for await event in events {
                guard let self else { return }
                self.handle(event)
            }
        }
    }

    public func stop() {
        task?.cancel()
        task = nil
    }

    func handle(_ event: Keyboard.Event) {
        guard event.isPressed else { return }
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

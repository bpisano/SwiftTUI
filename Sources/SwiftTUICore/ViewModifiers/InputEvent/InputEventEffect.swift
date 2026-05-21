//
//  InputEventEffect.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 26/04/2026.
//

import Foundation
import Terminal
import AttributeGraph

@MainActor
struct InputEventEffect<I: Input>: @MainActor Rule {
    private let modifier: Attribute<InputEventViewModifier<I>>
    private let phase: Attribute<ViewPhase>
    private let storage: Storage = .init()

    init(
        modifier: Attribute<InputEventViewModifier<I>>,
        phase: Attribute<ViewPhase>
    ) {
        self.modifier = modifier
        self.phase = phase
    }

    func evaluate() {
        let modifier = modifier.wrappedValue
        let isActive = phase.wrappedValue == .active

        defer {
            storage.wasActive = isActive
        }

        guard isActive else {
            guard storage.wasActive else { return }
            storage.task?.cancel()
            storage.task = nil
            return
        }

        storage.task?.cancel()
        storage.task = Task {
            let events = await modifier.input.events()

            for await event in events {
                guard !Task.isCancelled else { break }
                modifier.onEvent(event)
            }
        }
    }
}

private extension InputEventEffect {
    final class Storage {
        var wasActive: Bool = false
        var task: Task<Void, Never>?
    }
}

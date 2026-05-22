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
            storage.subscription?.cancel()
            storage.subscription = nil
            return
        }

        storage.subscription?.cancel()
        // Capture the runtime Graph so attribute writes inside the handler
        // (e.g. @State mutations from Button actions) trigger the right
        // `onInvalidate`. Dispatch hops through a detached background task
        // and would otherwise see the default graph.
        let graph: Graph = .current
        storage.subscription = modifier.input.subscribe { event in
            Graph.withCurrent(graph) {
                modifier.onEvent(event)
            }
        }
    }
}

private extension InputEventEffect {
    final class Storage {
        var wasActive: Bool = false
        var subscription: InputSubscription?
    }
}

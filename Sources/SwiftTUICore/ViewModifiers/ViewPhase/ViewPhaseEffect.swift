//
//  ViewPhaseEffect.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

struct ViewPhaseEffect: @MainActor EffectRule {
    private let modifier: Attribute<ViewPhaseViewModifier>
    private let phase: Attribute<ViewPhase>
    private let storage: Storage = .init()

    init(
        modifier: Attribute<ViewPhaseViewModifier>,
        phase: Attribute<ViewPhase>
    ) {
        self.modifier = modifier
        self.phase = phase
    }

    func update() {
        let modifier: ViewPhaseViewModifier = modifier.wrappedValue
        let isActive: Bool = phase.wrappedValue == .active
        let wasActive: Bool = storage.wasActive

        storage.wasActive = isActive

        if isActive && !wasActive {
            if let onAppear = modifier.onAppear {
                CallbackQueue.shared.enqueue(onAppear)
            }
        } else if !isActive && wasActive {
            if let onDisappear = modifier.onDisappear {
                CallbackQueue.shared.enqueue(onDisappear)
            }
        }
    }
}

private extension ViewPhaseEffect {
    final class Storage {
        var wasActive: Bool = false
    }
}

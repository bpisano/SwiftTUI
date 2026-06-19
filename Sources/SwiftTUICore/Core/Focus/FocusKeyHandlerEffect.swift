//
//  FocusKeyHandlerEffect.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 19/06/2026.
//

import Foundation
import Terminal
import AttributeGraph

/// Registers a focus-scoped key handler with the environment's ``FocusManager``
/// while the host view is on screen, and keeps the registration in sync with the
/// latest handler value.
///
/// The handler is delivered by ``FocusManager/dispatchKeyToFocused(_:)`` only
/// while its node holds focus — the focus check happens live at dispatch time,
/// so it never relies on the host view's `body` re-evaluating on a focus change.
@MainActor
struct FocusKeyHandlerEffect: @MainActor Rule {
    let environment: Attribute<EnvironmentValues>
    let nodeID: FocusNodeID
    let handler: Attribute<MainActorEventHandler<Keyboard.Event>>
    let isEnabled: Attribute<Bool>
    let phase: Attribute<ViewPhase>
    private let storage: Storage = .init()

    func evaluate() {
        let isActive: Bool = phase.wrappedValue == .active && isEnabled.wrappedValue
        let manager = environment.wrappedValue.focusManager

        // Tear down a stale registration when the field goes inactive or the
        // manager changes.
        if let token = storage.token, let previous = storage.manager,
           !isActive || previous !== manager {
            previous.unregisterKeyHandler(node: nodeID, token: token)
            storage.token = nil
            storage.manager = nil
        }

        guard isActive, let manager, storage.token == nil else { return }

        // Register once and read the handler *live* at dispatch — like
        // `InputEventEffect` reads `modifier.onEvent`. This always runs the
        // latest closure (capturing the current view value and its `@State`),
        // so per-keystroke state such as the caret position is never stale.
        let handler = self.handler
        let token = manager.registerKeyHandler(node: nodeID) { event in
            handler.wrappedValue(event)
        }
        storage.token = token
        storage.manager = manager
    }
}

private extension FocusKeyHandlerEffect {
    final class Storage {
        var token: UUID?
        var manager: FocusManager?
    }
}

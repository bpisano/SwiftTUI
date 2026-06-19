//
//  FocusKeyHandlerViewModifier.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 19/06/2026.
//

import Foundation
import Geometry
import Terminal
import AttributeGraph

/// Makes a view focusable and routes key events to it **only while it holds
/// focus**, checked live at dispatch time via the ``FocusManager``.
///
/// This is the shared building block behind focus-driven controls (``Button``,
/// ``TextField``). Unlike pairing ``View/focused(_:)`` with a global key
/// handler, the focus check happens against the live ``FocusManager/currentFocus``
/// when the key arrives — it never relies on the host view's `body` being
/// re-evaluated on a focus change, so the handler can't go stale.
struct FocusKeyHandlerViewModifier: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    let handler: MainActorEventHandler<Keyboard.Event>

    init(handler: @escaping @MainActor (Keyboard.Event) -> Void) {
        self.handler = .init(handler)
    }
}

extension FocusKeyHandlerViewModifier {
    static func makeView(
        _ modifier: Attribute<FocusKeyHandlerViewModifier>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        let nodeID: FocusNodeID = .init(modifier.id)
        let environment: Attribute<EnvironmentValues> = inputs.environment
        let position: Attribute<Point> = inputs.position
        let size: Attribute<Size> = inputs.size

        let isEnabled = Attribute("FocusKeyHandler isEnabled") {
            environment.wrappedValue.isEnabled
        }

        // Mirror the live focus into the child environment so a focus-driven
        // style (caret, etc.) tracks `currentFocus` directly.
        let childEnvironment = Attribute("FocusKeyHandler Environment") {
            var env = environment.wrappedValue
            env.isFocused = isEnabled.wrappedValue
                && env.focusManager?.currentFocus == nodeID
            return env
        }

        var modifiedInputs: ViewInputs = inputs
        modifiedInputs.environment = childEnvironment

        let handlerAttribute = modifier.map { $0.handler }
        handlerAttribute.label = "FocusKeyHandler handler"

        let effect = FocusKeyHandlerEffect(
            environment: environment,
            nodeID: nodeID,
            handler: handlerAttribute,
            isEnabled: isEnabled,
            phase: inputs.phase
        )
        let effectAttribute = Attribute(rule: effect)
        effectAttribute.flags = [.transactional]
        effectAttribute.label = "FocusKeyHandler effect"
        _ = effectAttribute.wrappedValue

        let childOutputs: ViewOutputs = makeViewOutputs(modifiedInputs)

        let focusList = Attribute("FocusKeyHandler FocusList") {
            guard isEnabled.wrappedValue else {
                return childOutputs.focusList?.wrappedValue ?? .empty
            }
            let frame = Rect(origin: position.wrappedValue, size: size.wrappedValue)
            let node = FocusableNode(id: nodeID, frame: frame, isEnabled: true)
            let selfList = FocusList(.node(node))
            if let childList = childOutputs.focusList?.wrappedValue {
                return selfList.appending(childList)
            }
            return selfList
        }

        return ViewOutputs(
            viewId: childOutputs.viewId,
            layoutComputer: childOutputs.layoutComputer,
            displayList: childOutputs.displayList,
            focusList: focusList
        )
    }
}

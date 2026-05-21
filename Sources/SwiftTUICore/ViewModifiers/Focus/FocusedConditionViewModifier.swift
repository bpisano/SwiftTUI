//
//  FocusedConditionViewModifier.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry
import AttributeGraph

struct FocusedConditionViewModifier<Value: Hashable & Sendable>: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    let binding: Binding<Value>
    let target: Value

    init(
        binding: Binding<Value>,
        target: Value
    ) {
        self.binding = binding
        self.target = target
    }
}

extension FocusedConditionViewModifier {
    static func makeView(
        _ modifier: Attribute<FocusedConditionViewModifier<Value>>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        let ownNodeID: FocusNodeID = .init(modifier.id)
        let position: Attribute<Point> = inputs.position
        let size: Attribute<Size> = inputs.size
        let syncState: SyncState = .init()

        let childEnvironment = Attribute("FocusedCondition Environment") {
            var env = inputs.environment.wrappedValue
            // Use own nodeID for env mirror. When the subtree already contains
            // a focusable, that inner focusable owns the real isFocused mirror
            // for its own children; our env update only matters when no inner
            // focusable exists.
            env.isFocused = env.focusManager?.currentFocus == ownNodeID
            return env
        }

        var modifiedInputs: ViewInputs = inputs
        modifiedInputs.environment = childEnvironment

        let resolvedChildOutputs: ViewOutputs = makeViewOutputs(modifiedInputs)

        let sync = Attribute("FocusedCondition Sync") {
            let modifierValue = modifier.wrappedValue
            let bound = modifierValue.binding.wrappedValue
            let target = modifierValue.target
            guard let manager = inputs.environment.wrappedValue.focusManager else { return }
            let current = manager.currentFocus

            let childList = resolvedChildOutputs.focusList?.wrappedValue ?? .empty
            let effectiveID = firstFocusableID(in: childList) ?? ownNodeID

            var nextLastBound = bound
            var nextLastCurrent = current

            defer {
                syncState.lastBound = nextLastBound
                syncState.lastCurrent = nextLastCurrent
                syncState.hasObserved = true
            }

            if !syncState.hasObserved {
                // First run: natural reconciliation without change detection.
                if bound == target, current != effectiveID {
                    CallbackQueue.shared.enqueue {
                        manager.setFocus(effectiveID)
                    }
                    nextLastCurrent = effectiveID
                } else if current == effectiveID, bound != target {
                    CallbackQueue.shared.enqueue {
                        modifierValue.binding.wrappedValue = target
                    }
                    nextLastBound = target
                }
                return
            }

            let boundChanged = syncState.lastBound != bound
            let currentChanged = syncState.lastCurrent != current

            // Only-manager-moved → mirror to binding.
            if currentChanged, !boundChanged {
                if current == effectiveID, bound != target {
                    CallbackQueue.shared.enqueue {
                        modifierValue.binding.wrappedValue = target
                    }
                    nextLastBound = target
                }
                return
            }

            // Only-binding-changed → claim focus when matching target.
            if boundChanged, !currentChanged {
                if bound == target, current != effectiveID {
                    CallbackQueue.shared.enqueue {
                        manager.setFocus(effectiveID)
                    }
                    nextLastCurrent = effectiveID
                }
                return
            }

            // Both changed in the same cycle → don't fight. State will settle.
        }

        let focusList = Attribute("FocusedCondition FocusList") {
            _ = sync.wrappedValue
            let childList = resolvedChildOutputs.focusList?.wrappedValue ?? .empty
            if firstFocusableID(in: childList) != nil {
                // Child subtree already provides a focusable — delegate to it.
                return childList
            }
            let frame = Rect(origin: position.wrappedValue, size: size.wrappedValue)
            let node = FocusableNode(id: ownNodeID, frame: frame, isEnabled: true)
            return FocusList(.node(node))
        }

        return ViewOutputs(
            viewId: resolvedChildOutputs.viewId,
            layoutComputer: resolvedChildOutputs.layoutComputer,
            displayList: resolvedChildOutputs.displayList,
            focusList: focusList
        )
    }

    private static func firstFocusableID(in list: FocusList) -> FocusNodeID? {
        for item in list.items {
            switch item {
            case .node(let node):
                return node.id
            case .list(let sublist):
                if let id = firstFocusableID(in: sublist) { return id }
            case .group(let group):
                if let id = firstFocusableID(in: group.children) { return id }
            }
        }
        return nil
    }
}

extension FocusedConditionViewModifier {
    @MainActor
    private final class SyncState {
        var hasObserved: Bool = false
        var lastBound: Value?
        var lastCurrent: FocusNodeID?
    }
}

extension View {
    public func focused<Value: Hashable & Sendable>(
        _ binding: Binding<Value>,
        equals value: Value
    ) -> some View {
        modifier(FocusedConditionViewModifier(binding: binding, target: value))
    }
}

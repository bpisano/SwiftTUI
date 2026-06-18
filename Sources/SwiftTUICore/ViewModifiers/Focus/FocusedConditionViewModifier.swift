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
    let binding: Binding<Value?>
    let target: Value

    init(
        binding: Binding<Value?>,
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

            let isFocused = current == effectiveID
            let matches = bound == target

            var nextLastBound = bound
            var nextLastCurrent = current

            defer {
                syncState.lastBound = nextLastBound
                syncState.lastCurrent = nextLastCurrent
                syncState.hasObserved = true
            }

            if !syncState.hasObserved {
                if matches, !isFocused {
                    CallbackQueue.shared.enqueue {
                        if modifierValue.binding.wrappedValue == target {
                            manager.setFocus(effectiveID)
                        }
                    }
                    nextLastCurrent = effectiveID
                } else if isFocused, !matches {
                    CallbackQueue.shared.enqueue {
                        if manager.currentFocus == effectiveID {
                            modifierValue.binding.wrappedValue = target
                        }
                    }
                    nextLastBound = target
                }
                return
            }

            let boundChanged = syncState.lastBound != bound
            let currentChanged = syncState.lastCurrent != current

            if currentChanged, !boundChanged {
                if isFocused, !matches {
                    CallbackQueue.shared.enqueue {
                        if manager.currentFocus == effectiveID {
                            modifierValue.binding.wrappedValue = target
                        }
                    }
                    nextLastBound = target
                } else if !isFocused, matches {
                    CallbackQueue.shared.enqueue {
                        if modifierValue.binding.wrappedValue == target {
                            modifierValue.binding.wrappedValue = nil
                        }
                    }
                    nextLastBound = nil
                }
                return
            }

            if boundChanged, !currentChanged {
                if matches, !isFocused {
                    CallbackQueue.shared.enqueue {
                        if modifierValue.binding.wrappedValue == target {
                            manager.setFocus(effectiveID)
                        }
                    }
                    nextLastCurrent = effectiveID
                } else if bound == nil, isFocused {
                    CallbackQueue.shared.enqueue {
                        if modifierValue.binding.wrappedValue == nil,
                           manager.currentFocus == effectiveID {
                            manager.clearFocus()
                        }
                    }
                    nextLastCurrent = nil
                }
                return
            }
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
    /// Binds the view's focus state to the given value.
    ///
    /// Focus is two-way: setting `binding` to `value` moves focus to this view,
    /// and when this view gains focus the binding is set to `value`. When focus
    /// leaves this view the binding is reset to `nil`, so the binding always
    /// reflects which value — if any — currently holds focus.
    ///
    /// ```swift
    /// enum Field { case name, email }
    ///
    /// @State private var focus: Field?
    ///
    /// TextField("Name", text: $name)
    ///     .focused($focus, equals: .name)
    /// TextField("Email", text: $email)
    ///     .focused($focus, equals: .email)
    /// ```
    ///
    /// Set the binding to `nil` to drop focus, or to a value to move focus to the
    /// matching view.
    ///
    /// - Parameters:
    ///   - binding: A binding whose optional value drives and reflects focus.
    ///   - value: The value that corresponds to this view being focused.
    public func focused<Value: Hashable & Sendable>(
        _ binding: Binding<Value?>,
        equals value: Value
    ) -> some View {
        modifier(FocusedConditionViewModifier(binding: binding, target: value))
    }
}

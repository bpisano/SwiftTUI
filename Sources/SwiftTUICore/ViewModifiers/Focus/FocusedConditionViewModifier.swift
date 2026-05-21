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
        let nodeID: FocusNodeID = .init(modifier.id)
        let position: Attribute<Point> = inputs.position
        let size: Attribute<Size> = inputs.size

        let childEnvironment = Attribute("FocusedCondition Environment") {
            var env = inputs.environment.wrappedValue
            env.isFocused = env.focusManager?.currentFocus == nodeID
            return env
        }

        var modifiedInputs: ViewInputs = inputs
        modifiedInputs.environment = childEnvironment

        let childOutputs: ViewOutputs = makeViewOutputs(modifiedInputs)

        let sync = Attribute("FocusedCondition Sync") {
            let modifierValue = modifier.wrappedValue
            let bound = modifierValue.binding.wrappedValue
            let target = modifierValue.target
            guard let manager = inputs.environment.wrappedValue.focusManager else { return }
            let current = manager.currentFocus

            if bound == target, current != nodeID {
                CallbackQueue.shared.enqueue {
                    manager.setFocus(nodeID)
                }
            } else if current == nodeID, bound != target {
                CallbackQueue.shared.enqueue {
                    modifierValue.binding.wrappedValue = target
                }
            }
        }

        let focusList = Attribute("FocusedCondition FocusList") {
            _ = sync.wrappedValue
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

extension View {
    public func focused<Value: Hashable & Sendable>(
        _ binding: Binding<Value>,
        equals value: Value
    ) -> some View {
        modifier(FocusedConditionViewModifier(binding: binding, target: value))
    }
}

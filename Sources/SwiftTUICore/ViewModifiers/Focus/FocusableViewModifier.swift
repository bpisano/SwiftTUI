//
//  FocusableViewModifier.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry
import AttributeGraph

struct FocusableViewModifier: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    let isEnabled: Bool

    init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
}

extension FocusableViewModifier {
    static func makeView(
        _ modifier: Attribute<FocusableViewModifier>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        let nodeID: FocusNodeID = .init(modifier.id)
        let position: Attribute<Point> = inputs.position
        let size: Attribute<Size> = inputs.size

        let childEnvironment = Attribute("Focusable Environment") {
            var env = inputs.environment.wrappedValue
            env.isFocused = env.focusManager?.currentFocus == nodeID
            return env
        }

        var modifiedInputs: ViewInputs = inputs
        modifiedInputs.environment = childEnvironment

        let childOutputs: ViewOutputs = makeViewOutputs(modifiedInputs)

        let focusList = Attribute("Focusable FocusList") {
            let frame = Rect(origin: position.wrappedValue, size: size.wrappedValue)
            let isEnabled = modifier.wrappedValue.isEnabled
            let node = FocusableNode(id: nodeID, frame: frame, isEnabled: isEnabled)
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
    public func focusable(_ isEnabled: Bool = true) -> some View {
        modifier(FocusableViewModifier(isEnabled: isEnabled))
    }
}

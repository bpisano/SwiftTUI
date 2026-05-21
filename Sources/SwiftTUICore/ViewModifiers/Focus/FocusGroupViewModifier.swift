//
//  FocusGroupViewModifier.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph

struct FocusGroupViewModifier: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    init() {}
}

extension FocusGroupViewModifier {
    static func makeView(
        _ modifier: Attribute<FocusGroupViewModifier>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        let groupID: FocusNodeID = .init(modifier.id)
        let childOutputs: ViewOutputs = makeViewOutputs(inputs)

        let focusList = Attribute("FocusGroup FocusList") {
            let inner: FocusList = childOutputs.focusList?.wrappedValue ?? .empty
            guard !inner.items.isEmpty else { return FocusList.empty }
            return FocusList(.group(FocusGroup(id: groupID, children: inner)))
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
    public func focusGroup() -> some View {
        modifier(FocusGroupViewModifier())
    }
}

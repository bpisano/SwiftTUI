//
//  Optional+View.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 09/04/2026.
//

import Foundation
import AttributeGraph

extension Optional: PrimitiveView where Wrapped: View {}

extension Optional: View where Wrapped: View {
    public typealias Body = Never

    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let rule: OptionalViewOutputsRule<Wrapped> = .init(view: view, inputs: inputs)
        let viewOutputs: Attribute<ViewOutputs> = Attribute(
            "OptionalView ViewOutputs",
            rule: rule
        )

        let layoutComputer = Attribute("OptionalView LayoutComputer") {
            viewOutputs.wrappedValue.layoutComputer.wrappedValue
        }

        let displayList = Attribute("OptionalView DisplayList") {
            viewOutputs.wrappedValue.displayList.wrappedValue
        }

        let focusList = Attribute("OptionalView FocusList") {
            viewOutputs.wrappedValue.focusList?.wrappedValue ?? .empty
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList,
            focusList: focusList
        )
    }

    public static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let rule: OptionalViewListRule<Wrapped> = .init(view: view, inputs: inputs)
        let viewList = Attribute("OptionalView ViewList", rule: rule)
        return ViewListOutputs(views: .dynamicList(viewList), nextImplicitId: inputs.implicitId + 1)
    }
}

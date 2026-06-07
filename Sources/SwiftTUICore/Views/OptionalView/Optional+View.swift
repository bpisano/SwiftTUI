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
}

@MainActor
extension Optional: DynamicView where Wrapped: View {
    var dynamicBranchId: AnyHashable {
        AnyHashable(self != nil)
    }

    static func makeDynamicChildView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        if view.wrappedValue != nil {
            return Wrapped.makeView(contentChild(of: view), inputs: inputs)
        } else {
            let child: Attribute<EmptyView> = .init("Optional Empty Child") { .init() }
            return EmptyView.makeView(child, inputs: inputs)
        }
    }

    static func makeDynamicChildViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        if view.wrappedValue != nil {
            return Wrapped.makeViewList(contentChild(of: view), inputs: inputs)
        } else {
            let child: Attribute<EmptyView> = .init("Optional Empty Child") { .init() }
            return EmptyView.makeViewList(child, inputs: inputs)
        }
    }

    private static func contentChild(of view: Attribute<Self>) -> Attribute<Wrapped> {
        .init("Optional Content Child", rule: DynamicChildRule(parent: view) { $0 })
    }
}

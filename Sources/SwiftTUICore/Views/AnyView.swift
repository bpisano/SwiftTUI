//
//  AnyView.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph

public struct AnyView: View, PrimitiveView, DynamicView {
    private let storage: Any
    private let _makeView: @MainActor (Attribute<AnyView>, ViewInputs) -> ViewOutputs
    private let _makeViewList: @MainActor (Attribute<AnyView>, ViewListInputs) -> ViewListOutputs

    public init<V: View>(_ view: V) {
        self.storage = view
        self._makeView = { anyViewAttribute, inputs in
            V.makeView(Self.child(of: anyViewAttribute), inputs: inputs)
        }
        self._makeViewList = { anyViewAttribute, inputs in
            V.makeViewList(Self.child(of: anyViewAttribute), inputs: inputs)
        }
    }

    private static func child<V: View>(of view: Attribute<Self>) -> Attribute<V> {
        let child: Attribute<V> = .init("\(V.self)", rule: DynamicChildRule(parent: view) { $0.storage as? V })
        return child
    }
}

extension AnyView {
    var dynamicBranchId: AnyHashable {
        AnyHashable(ObjectIdentifier(type(of: storage)))
    }

    static func makeDynamicChildView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        view.wrappedValue._makeView(view, inputs)
    }

    static func makeDynamicChildViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        view.wrappedValue._makeViewList(view, inputs)
    }
}

extension AnyView: @MainActor AttributeValueRepresentable {
    public var attributeValueDescription: String {
        "AnyView"
    }
}

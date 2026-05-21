//
//  AnyView.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph

public struct AnyView: View, PrimitiveView {
    private let storage: Any
    private let _makeView: @MainActor (Attribute<AnyView>, ViewInputs) -> ViewOutputs
    private let _makeViewList: @MainActor (Attribute<AnyView>, ViewListInputs) -> ViewListOutputs

    public init<V: View>(_ view: V) {
        self.storage = view
        self._makeView = { anyViewAttribute, inputs in
            let innerAttribute: Attribute<V> = anyViewAttribute.map {
                $0.storage as! V
            }
            innerAttribute.label = "\(V.self)"
            return V.makeView(innerAttribute, inputs: inputs)
        }
        self._makeViewList = { anyViewAttribute, inputs in
            let innerAttribute: Attribute<V> = anyViewAttribute.map {
                $0.storage as! V
            }
            innerAttribute.label = "\(V.self)"
            return V.makeViewList(innerAttribute, inputs: inputs)
        }
    }
}

extension AnyView {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        view.wrappedValue._makeView(view, inputs)
    }

    public static func makeViewList(
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

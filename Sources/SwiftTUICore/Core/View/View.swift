//
//  View.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

@MainActor
public protocol View {
    associatedtype Body: View

    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs

    @ViewBuilder
    var body: Self.Body { get }
}

extension View {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let body = view.map(\.body)
        body.label = "\(Body.self)"
        view.updateDynamicProperties()
        return Body.makeView(body, inputs: inputs)
    }

    public static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let body = view.map(\.body)
        body.label = "\(Body.self)"
        view.updateDynamicProperties()
        return Body.makeViewList(body, inputs: inputs)
    }
}

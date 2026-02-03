//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import AttributeGraph
import Foundation
import Geometry

public protocol View {
    associatedtype Body: View

    static func makeView(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs
    static func makeViewList(_ view: Attribute<Self>, inputs: ViewListInputs) -> ViewListOutputs
    static func viewListCount(inputs: ViewListCountInputs) -> Int?

    @ViewBuilder
    var body: Body { get }
}

public extension View {
    static func makeView(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs {
        let body = view.map(\.body)
        body.label = "\(Self.self) body"
        view.updateDynamicProperties()
        return Body.makeView(body, inputs: inputs)
    }

    static func makeViewList(_ view: Attribute<Self>, inputs: ViewListInputs) -> ViewListOutputs {
        let body = view.map(\.body)
        body.label = "\(Self.self) body"
        view.updateDynamicProperties()
        return Body.makeViewList(body, inputs: inputs)
    }

    static func viewListCount(inputs: ViewListCountInputs) -> Int? {
        Body.viewListCount(inputs: inputs)
    }
}

//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import AttributeGraph
import Foundation
import Geometry

protocol View {
    static func makeView(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs
    static func makeViewList(_ view: Attribute<Self>, inputs: ViewListInputs) -> ViewListOutputs
    static func viewListCount(inputs: ViewListCountInputs) -> Int?
}

protocol PrimitiveView: View {}

protocol UnaryView: View {}

extension UnaryView {
    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .unaryViewList(viewType: Self.self, inputs: inputs) { viewInputs in
            Self.makeView(view, inputs: viewInputs)
        }
    }

    static func viewListCount(inputs: ViewListCountInputs) -> Int? {
        1
    }
}

protocol MultiView: View {}

//
//  UnaryView.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import AttributeGraph

protocol UnaryView: View {}

extension UnaryView {
    public static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .unaryViewList(inputs: inputs) { viewInputs in
            return Self.makeView(view, inputs: viewInputs)
        }
    }

    public static func viewListCount(inputs: ViewListCountInputs) -> Int? {
        1
    }
}

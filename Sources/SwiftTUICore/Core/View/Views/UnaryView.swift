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
        .unaryViewList(viewType: Self.self, inputs: inputs) { viewInputs in
            Self.makeView(view, inputs: viewInputs)
        }
    }

    public static func viewListCount(inputs: ViewListCountInputs) -> Int? {
        1
    }
}

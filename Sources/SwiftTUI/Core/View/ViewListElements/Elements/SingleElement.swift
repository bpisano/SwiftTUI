//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import Foundation
import AttributeGraph

struct SingleElement<V: View>: ViewListElements {
    let count: Int = 1

    private let view: Attribute<V>

    init(_ view: Attribute<V>) {
        self.view = view
    }

    func makeElements(
        from startIndex: Int,
        inputs: ViewInputs,
        callback: (ViewOutputs) -> Bool
    ) {
        let outputs: ViewOutputs = V.makeView(view, inputs: inputs)
        _ = callback(outputs)
    }
}

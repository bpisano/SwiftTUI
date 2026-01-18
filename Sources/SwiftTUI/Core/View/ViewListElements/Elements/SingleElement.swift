//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import AttributeGraph
import Foundation

struct SingleElement<V: View>: ViewListElements {
    let count: Int = 1

    private let view: Attribute<V>

    init(_ view: Attribute<V>) {
        self.view = view
    }

    func makeElements(
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    ) -> (ViewOutputs?, Bool) {
        let makeElement: MakeElement = { inputs in
            V.makeView(view, inputs: inputs)
        }
        let result = body(&start, inputs, makeElement)
        start += 1
        return result
    }
}

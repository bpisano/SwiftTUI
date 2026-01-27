//
//  UnaryElement.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/12/2025.
//

import Foundation

struct UnaryElement: ViewListElements {
    private let makeBody: (ViewInputs) -> ViewOutputs

    var count: Int { 1 }

    init(_ makeBody: @escaping (ViewInputs) -> ViewOutputs) {
        self.makeBody = makeBody
    }

    func makeElements(
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    ) -> (ViewOutputs?, Bool) {
        let makeElement: MakeElement = { inputs in
            makeBody(inputs)
        }
        let result = body(&start, inputs, makeElement)
        start += 1
        return result
    }
}

//
//  UnaryElement.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/12/2025.
//

import Foundation

struct UnaryElement: ViewListElements {
    private let makeBody: (ViewInputs) -> ViewOutputs

    let count: Int = 1

    init(_ makeBody: @escaping (ViewInputs) -> ViewOutputs) {
        self.makeBody = makeBody
    }

    func makeElements(
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    ) -> (ViewOutputs?, Bool) {
        let outputs = body(&start, inputs) { modifiedInputs in
            makeBody(modifiedInputs)
        }
        start += 1
        return outputs
    }
}

extension UnaryElement: CustomStringConvertible {
    var description: String {
        "UnaryElement"
    }
}

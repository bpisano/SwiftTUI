//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import Foundation

struct MergedElements: ViewListElements {
    var count: Int {
        elements.reduce(0) { $0 + $1.count }
    }

    private let elements: [any ViewListElements]

    init(_ elements: [any ViewListElements]) {
        self.elements = elements
    }

    func makeElements(
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    ) -> (ViewOutputs?, Bool) {
        var lastResult: (ViewOutputs?, Bool) = (nil, false)
        for element in elements {
            lastResult = element.makeElements(from: &start, inputs: inputs, body: body)
        }
        return lastResult
    }
}

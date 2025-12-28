//
//  UnaryElement.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/12/2025.
//

import Foundation

struct UnaryElement: ViewListElements {
    private let body: (ViewInputs) -> ViewOutputs

    var count: Int { 1 }

    init(_ body: @escaping (ViewInputs) -> ViewOutputs) {
        self.body = body
    }

    func makeElements(
        from startIndex: Int,
        inputs: ViewInputs,
        callback: (ViewOutputs) -> Bool
    ) {
        let outputs: ViewOutputs = body(inputs)
        _ = callback(outputs)
    }
}

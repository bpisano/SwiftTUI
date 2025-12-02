//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import Foundation

struct BaseViewList: ViewList {
    var count: Int { elements.count }

    private let elements: any ViewListElements

    init(elements: any ViewListElements) {
        self.elements = elements
    }

    func makeViews(
        from startIndex: Int,
        inputs: ViewInputs,
        callback: (ViewOutputs) -> Void
    ) {
        elements.makeElements(from: startIndex, inputs: inputs) { viewOutputs in
            callback(viewOutputs)
            return true
        }
    }
}

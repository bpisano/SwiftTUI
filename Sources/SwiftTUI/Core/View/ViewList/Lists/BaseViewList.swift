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
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    ) {
        withoutActuallyEscaping(body) { escapingBody in
            _ = elements.makeElements(from: &start, inputs: inputs, body: escapingBody)
        }
    }
}

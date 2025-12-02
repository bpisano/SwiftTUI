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
        from startIndex: Int,
        inputs: ViewInputs,
        callback: (ViewOutputs) -> Bool
    ) {
        var currentIndex: Int = 0

        for element in elements {
            let childCount: Int = element.count

            if startIndex <= currentIndex {
                // We're past the startIndex, so create all remaining elements
                element.makeElements(
                    from: 0,
                    inputs: inputs,
                    callback: callback
                )
            } else if startIndex < currentIndex + childCount {
                // startIndex falls within this element's range
                let childStartIndex: Int = startIndex - currentIndex
                element.makeElements(
                    from: childStartIndex,
                    inputs: inputs,
                    callback: callback
                )
            }

            currentIndex += childCount
        }
    }
}

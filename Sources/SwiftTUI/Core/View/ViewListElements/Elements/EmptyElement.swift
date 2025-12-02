//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import Foundation

struct EmptyElement: ViewListElements {
    let count: Int = 0

    func makeElements(
        from startIndex: Int,
        inputs: ViewInputs,
        callback: (ViewOutputs) -> Bool
    ) {}
}

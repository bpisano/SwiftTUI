//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import Foundation

protocol ViewListElements {
    var count: Int { get }

    func makeElements(
        from startIndex: Int,
        inputs: ViewInputs,
        callback: (ViewOutputs) -> Bool
    )
}

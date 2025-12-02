//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import Foundation

protocol ViewList {
    typealias Elements = ViewListElements

    var count: Int { get }

    func makeViews(
        from startIndex: Int,
        inputs: ViewInputs,
        callback: (ViewOutputs) -> Void
    )
}

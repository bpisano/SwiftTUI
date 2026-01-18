//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import Foundation

protocol ViewListElements {
    typealias Body = (inout Int, ViewInputs, @escaping MakeElement) -> (ViewOutputs?, Bool)
    typealias MakeElement = (ViewInputs) -> ViewOutputs

    var count: Int { get }

    func makeElements(
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    ) -> (ViewOutputs?, Bool)
}

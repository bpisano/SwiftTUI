//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import Foundation

protocol ViewList {
    typealias Elements = ViewListElements
    typealias Body = (inout Int, ViewInputs, @escaping MakeElement) -> (ViewOutputs?, Bool)
    typealias MakeElement = (ViewInputs) -> ViewOutputs

    var count: Int { get }
    var viewIds: ViewId.Views? { get }

    func makeViews(
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    )
}

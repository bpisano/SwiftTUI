//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation

struct BodyInput<Token>: ViewInputKey {
    typealias Value = BodyInputElement
}

enum BodyInputElement {
    typealias MakeViewBody = (ViewInputs) -> ViewOutputs
    typealias MakeViewListBody = (ViewListInputs) -> ViewListOutputs

    case view(MakeViewBody)
    case list(MakeViewListBody)
}

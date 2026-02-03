//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation

struct BodyCountInput<Token>: ViewInputKey {
    typealias Value = (ViewListCountInputs) -> Int?
}

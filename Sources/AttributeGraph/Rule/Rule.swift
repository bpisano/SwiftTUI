//
//  Rule.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

@MainActor
public protocol Rule {
    associatedtype Value

    func evaluate() -> Value
}

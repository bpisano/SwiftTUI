//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 25/11/2025.
//

import Foundation

public struct ComputedRule<T>: Rule {
    private let compute: () -> T

    public init(_ compute: @escaping () -> T) {
        self.compute = compute
    }

    public func evaluate() -> T {
        compute()
    }
}

extension Attribute {
    public init(
        _ label: String? = nil,
        _ compute: @escaping () -> T
    ) {
        self.init(
            label,
            rule: ComputedRule(compute)
        )
    }
}

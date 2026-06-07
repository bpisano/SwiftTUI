//
//  DynamicChildRule.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 06/06/2026.
//

import Foundation
import AttributeGraph

@MainActor
final class DynamicChildRule<Parent, Child>: Rule {
    typealias Value = Child

    @Attribute private var parent: Parent

    private let extract: (Parent) -> Child?
    private var lastValue: Child?

    init(
        parent: Attribute<Parent>,
        initialValue: Child? = nil,
        extract: @escaping (Parent) -> Child?
    ) {
        self._parent = parent
        self.lastValue = initialValue
        self.extract = extract
    }

    func evaluate() -> Child {
        if let value = extract(parent) {
            lastValue = value
        }
        guard let lastValue else {
            preconditionFailure("DynamicChildRule evaluated before its branch was ever active")
        }
        return lastValue
    }
}

//
//  AnyRule.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

struct AnyRule<T>: Rule {
    private let _evaluate: () -> T

    init<R: Rule>(_ rule: R) where R.Value == T {
        self._evaluate = rule.evaluate
    }

    func evaluate() -> T {
        _evaluate()
    }
}

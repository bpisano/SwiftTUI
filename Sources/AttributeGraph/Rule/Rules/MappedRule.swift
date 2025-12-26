//
//  MappedRule.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 26/12/2025.
//

import Foundation

struct MappedRule<T, U>: Rule {
    let parent: Attribute<T>
    let transform: (T) -> U
    
    func evaluate() -> U {
        transform(parent.wrappedValue)
    }
}

extension Attribute {
    public func map<U>(_ transform: @escaping (T) -> U) -> Attribute<U> {
        Attribute<U>(rule: MappedRule(parent: self, transform: transform))
    }

    public func map<U>(_ keyPath: KeyPath<T, U>) -> Attribute<U> {
        map { $0[keyPath: keyPath] }
    }
}

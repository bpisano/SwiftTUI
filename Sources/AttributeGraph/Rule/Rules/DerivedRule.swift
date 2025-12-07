//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/12/2025.
//

import Foundation

public struct DerivedRule<Base, Member>: Rule {
    private let base: Attribute<Base>
    private let keyPath: KeyPath<Base, Member>

    public init(base: Attribute<Base>, keyPath: KeyPath<Base, Member>) {
        self.base = base
        self.keyPath = keyPath
    }

    public func evaluate() -> Member {
        base.wrappedValue[keyPath: keyPath]
    }
}

extension Attribute {
    public subscript<Member>(_ keyPath: KeyPath<T, Member>) -> Attribute<Member> {
        Attribute<Member>(rule: DerivedRule(base: self, keyPath: keyPath))
    }
}

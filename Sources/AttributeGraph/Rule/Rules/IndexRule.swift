//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 18/01/2026.
//

import Foundation

struct IndexRule<T: Collection>: Rule {
    let parent: Attribute<T>
    let index: T.Index

    func evaluate() -> T.Element {
        parent.wrappedValue[index]
    }
}

extension Attribute where T: Collection {
    public func index(_ index: T.Index) -> Attribute<T.Element> {
        Attribute<T.Element>(rule: IndexRule(parent: self, index: index))
    }
}

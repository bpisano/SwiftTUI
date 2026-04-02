//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

final class AttributeRef {
    var attribute: AnyAttribute

    init(_ ref: AnyAttribute) {
        self.attribute = ref
    }
}

extension AttributeRef: Hashable, Equatable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: AttributeRef, rhs: AttributeRef) -> Bool {
        lhs === rhs
    }
}

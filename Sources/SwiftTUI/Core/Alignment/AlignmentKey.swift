//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation

struct AlignmentKey: Hashable {
    let id: AlignmentID.Type
    let axis: Axis

    init(id: AlignmentID.Type, axis: Axis) {
        self.id = id
        self.axis = axis
    }
}

extension AlignmentKey {
    static func == (lhs: AlignmentKey, rhs: AlignmentKey) -> Bool {
        ObjectIdentifier(lhs.id) == ObjectIdentifier(rhs.id) &&
        lhs.axis == rhs.axis
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(id))
        hasher.combine(axis)
    }
}

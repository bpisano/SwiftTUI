//
//  MergedViewIds.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 24/02/2026.
//

import Foundation

struct MergedViewIds: @MainActor ViewIdCollection {
    let startIndex: Int = 0
    let endIndex: Int

    private let bases: [ViewId.Views]

    init(_ bases: [ViewId.Views]) {
        self.bases = bases
        endIndex = bases.reduce(0) { $0 + $1.count }
    }

    subscript(index: Int) -> ViewId {
        var index = index
        for base in bases {
            if index < base.count {
                return base[index]
            }
            index -= base.count
        }
        fatalError("Index out of bounds")
    }
}

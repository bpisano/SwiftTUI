//
//  MappedViewIds.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 24/02/2026.
//

import Foundation

struct MappedViewIds: @MainActor ViewIdCollection {
    let startIndex: Int
    let endIndex: Int

    private let base: any ViewIdCollection
    private let map: (ViewId) -> ViewId

    init(
        base: any ViewIdCollection,
        map: @escaping (ViewId) -> ViewId
    ) {
        self.base = base
        self.map = map
        self.startIndex = base.startIndex
        self.endIndex = base.endIndex
    }

    subscript(index: Int) -> ViewId {
        map(base[index])
    }
}

extension ViewIdCollection {
    func map(_ transform: @escaping (ViewId) -> ViewId) -> some ViewIdCollection {
        MappedViewIds(base: self, map: transform)
    }
}

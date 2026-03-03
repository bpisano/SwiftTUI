//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 24/02/2026.
//

import Foundation

struct ImplicitViewIds: @MainActor ViewIdCollection {
    let startIndex: Int = 0
    let endIndex: Int

    private let implicitId: Int
    private let explicitIds: [ViewId.Explicit]

    init(
        implicitId: Int,
        explicitIds: [ViewId.Explicit],
        count: Int
    ) {
        self.implicitId = implicitId
        self.explicitIds = explicitIds
        self.endIndex = count
    }

    subscript(index: Int) -> ViewId {
        var id: ViewId = .init(implicitId: implicitId, index: index)
        id.explicit = explicitIds
        return id
    }
}

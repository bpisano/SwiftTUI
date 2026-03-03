//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 22/02/2026.
//

import Foundation
import AttributeGraph

struct ViewId {
    typealias Views = any ViewIdCollection

    let implicitId: Int
    let index: Int
    var explicit: [Explicit] = []

    init(
        implicitId: Int,
        index: Int = 0,
    ) {
        self.implicitId = implicitId
        self.index = index
    }
}

extension ViewId {
    struct Explicit {
        let id: AnyHashable
    }
}

extension ViewId: CustomStringConvertible {
    var description: String {
        "ViewId(implicitId: \(implicitId), index: \(index), explicit: \(explicit.map(\.id))"
    }
}

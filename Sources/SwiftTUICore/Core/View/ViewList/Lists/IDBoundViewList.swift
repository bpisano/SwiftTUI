//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 23/02/2026.
//

import Foundation

struct IDBoundViewList: ViewList {
    var count: Int { base.count }
    var viewIds: ViewId.Views? {
        base.viewIds?.map { viewId in
            var id = viewId
            id.explicit = explicit
            return id
        }
    }

    private let base: ViewList
    private let explicit: ViewId.Explicit

    init(
        base: ViewList,
        explicit: ViewId.Explicit
    ) {
        self.base = base
        self.explicit = explicit
    }

    func makeViews(
        from start: inout Int,
        inputs: ViewInputs,
        body: (inout Int, ViewInputs, @escaping MakeElement) -> (ViewOutputs?, Bool)
    ) {
        base.makeViews(from: &start, inputs: inputs, body: body)
    }
}

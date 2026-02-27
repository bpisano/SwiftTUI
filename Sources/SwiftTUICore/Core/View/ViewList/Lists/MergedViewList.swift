//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation

struct MergedViewList: ViewList {
    let count: Int
    let viewIds: ViewId.Views?

    private let lists: [ViewList]

    init(_ lists: [ViewList]) {
        self.lists = lists
        self.count = lists.reduce(0) { $0 + $1.count }
        self.viewIds = MergedViewIds(lists.compactMap(\.viewIds))
    }

    func makeViews(
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    ) {
        withoutActuallyEscaping(body) { escapingBody in
            for list in lists {
                list.makeViews(from: &start, inputs: inputs, body: escapingBody)
            }
        }
    }
}

extension MergedViewList: CustomStringConvertible {
    var description: String {
        "MergedViewList"
    }
}

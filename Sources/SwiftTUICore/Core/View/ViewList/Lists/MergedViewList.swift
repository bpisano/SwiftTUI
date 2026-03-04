//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation
import AttributeGraph

struct MergedViewList: ViewList {
    let count: Int
    let viewIds: ViewId.Views?

    private let lists: [Attribute<ViewList>]

    init(_ lists: [Attribute<ViewList>]) {
        self.lists = lists
        self.count = lists.reduce(0) { $0 + $1.wrappedValue.count }
        self.viewIds = MergedViewIds(lists.compactMap(\.wrappedValue.viewIds))
    }

    func makeViews(
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    ) {
        withoutActuallyEscaping(body) { escapingBody in
            for list in lists {
                list.wrappedValue.makeViews(
                    from: &start,
                    inputs: inputs,
                    body: escapingBody
                )
            }
        }
    }
}

extension MergedViewList: CustomStringConvertible {
    var description: String {
        "MergedViewList"
    }
}

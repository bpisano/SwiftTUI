//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation

struct MergedViewList: ViewList {
    var count: Int {
        lists.reduce(0) { $0 + $1.count }
    }

    private let lists: [ViewList]

    init(_ lists: [ViewList]) {
        self.lists = lists
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

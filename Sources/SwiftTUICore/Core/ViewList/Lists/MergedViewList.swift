//
//  MergedViewList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

@MainActor
struct MergedViewList: ViewList {
    private let viewLists: [Attribute<any ViewList>]

    init(viewLists: [Attribute<any ViewList>]) {
        self.viewLists = viewLists
    }

    var viewIds: [ViewId]? {
        var ids: [ViewId] = []
        for viewList in viewLists {
            guard let subIds = viewList.wrappedValue.viewIds else { return nil }
            ids.append(contentsOf: subIds)
        }
        return ids
    }

    func applyItems(_ body: (RetainedViewListItem) -> Void) {
        for viewList in viewLists {
            viewList.wrappedValue.applyItems(body)
        }
    }
}

extension MergedViewList: @MainActor AttributeValueRepresentable {
    var attributeValueDescription: String {
        "MergedViewList with \(viewLists.count) lists"
    }
}

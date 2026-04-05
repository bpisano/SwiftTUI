//
//  MergedViewList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

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

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        withoutActuallyEscaping(makeViewOutputs) { escapingMakeViewOutputs in
            viewLists.flatMap { viewList in
                viewList.wrappedValue.makeViewOutputs(
                    startIndex: &startIndex,
                    inputs: inputs,
                    makeViewOutputs: escapingMakeViewOutputs
                )
            }
        }
    }
}

extension MergedViewList: AttributeValueRepresentable {
    var attributeValueDescription: String {
        "MergedViewList with \(viewLists.count) lists"
    }
}

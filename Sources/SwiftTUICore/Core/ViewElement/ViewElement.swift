//
//  ViewElement.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

protocol ViewElement {
    typealias MakeViewOutputs = ViewListMakeViewOutputs
    typealias MakeViewOutputsInterceptor = ViewListMakeViewOutputsInterceptor

    var viewId: ViewId { get }
    var retainedViewIds: [ViewId] { get }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> ViewOutputs?

    @MainActor
    func retainedViewListItem() -> RetainedViewListItem?
}

extension ViewElement {
    var retainedViewIds: [ViewId] { [viewId] }

    @MainActor
    func retainedViewListItem() -> RetainedViewListItem? {
        let retainedViewIds = retainedViewIds
        guard !retainedViewIds.isEmpty else { return nil }

        return RetainedViewListItem(viewIds: retainedViewIds) { startIndex, inputs, makeViewOutputs in
            guard let viewOutputs = self.makeViewOutputs(
                startIndex: &startIndex,
                inputs: inputs,
                makeViewOutputs: makeViewOutputs
            ) else {
                return []
            }
            return [viewOutputs]
        }
    }
}

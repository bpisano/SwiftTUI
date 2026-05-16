//
//  ViewList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

typealias ViewListMakeViewOutputs = (_ inputs: ViewInputs) -> ViewOutputs
typealias ViewListMakeViewOutputsInterceptor = (
    _ startIndex: inout Int,
    _ viewId: ViewId,
    _ inputs: ViewInputs,
    _ makeViewOutputs: ViewListMakeViewOutputs
) -> ViewOutputs?

struct RetainedViewListItem {
    typealias MakeViewOutputs = @MainActor (
        _ startIndex: inout Int,
        _ inputs: ViewInputs,
        _ makeViewOutputs: @escaping ViewListMakeViewOutputsInterceptor
    ) -> [ViewOutputs]

    let identity: AnyHashable
    let viewIds: [ViewId]

    private let makeViewOutputsClosure: MakeViewOutputs

    init(
        identity: AnyHashable? = nil,
        viewIds: [ViewId],
        makeViewOutputs: @escaping MakeViewOutputs
    ) {
        self.identity = identity ?? AnyHashable(viewIds)
        self.viewIds = viewIds
        self.makeViewOutputsClosure = makeViewOutputs
    }

    var count: Int { viewIds.count }

    @MainActor
    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: @escaping ViewListMakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        makeViewOutputsClosure(&startIndex, inputs, makeViewOutputs)
    }
}

@MainActor
protocol ViewList {
    typealias MakeViewOutputs = ViewListMakeViewOutputs
    typealias MakeViewOutputsInterceptor = ViewListMakeViewOutputsInterceptor

    var viewIds: [ViewId]? { get }

    func applyItems(_ body: (RetainedViewListItem) -> Void)
}

extension ViewList {
    @MainActor
    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        var outputs: [ViewOutputs] = []
        applyItems { item in
            outputs.append(
                contentsOf: item.makeViewOutputs(
                    startIndex: &startIndex,
                    inputs: inputs,
                    makeViewOutputs: makeViewOutputs
                )
            )
        }
        return outputs
    }

    @MainActor
    func makeViewOutputs(inputs: ViewInputs) -> [ViewOutputs] {
        var index: Int = 0
        return makeViewOutputs(startIndex: &index, inputs: inputs) { index, viewId, inputs, makeViewOutputs in
            makeViewOutputs(inputs).withViewId(viewId)
        }
    }
}

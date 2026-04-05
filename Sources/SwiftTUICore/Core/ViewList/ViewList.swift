//
//  ViewList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

protocol ViewList {
    typealias MakeViewOutputs = (_ inputs: ViewInputs) -> ViewOutputs
    typealias MakeViewOutputsInterceptor = (
        _ index: inout Int,
        _ viewId: ViewId,
        _ inputs: ViewInputs,
        _ makeViewOutputs: MakeViewOutputs
    ) -> ViewOutputs?

    var viewIds: [ViewId]? { get }

    @MainActor
    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputsInterceptor
    ) -> [ViewOutputs]
}

extension ViewList {
    @MainActor
    func makeViewOutputs(inputs: ViewInputs) -> [ViewOutputs] {
        var index: Int = 0
        return makeViewOutputs(startIndex: &index, inputs: inputs) { index, viewId, inputs, makeViewOutputs in
            makeViewOutputs(inputs)
        }
    }
}

//
//  UnaryViewElement.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

struct UnaryViewElement: ViewElement {
    typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs

    let viewId: ViewId
    private let makeOutputs: MakeViewOutputs

    init(viewId: ViewId, makeOutputs: @escaping MakeViewOutputs) {
        self.viewId = viewId
        self.makeOutputs = makeOutputs
    }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> ViewOutputs? {
        let viewOutputs: ViewOutputs? = makeViewOutputs(&startIndex, viewId, inputs, makeOutputs)
        if viewOutputs != nil {
            startIndex += 1
        }
        return viewOutputs
    }
}

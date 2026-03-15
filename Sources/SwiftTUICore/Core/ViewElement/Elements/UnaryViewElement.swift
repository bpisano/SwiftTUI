//
//  UnaryViewElement.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

struct UnaryViewElement: ViewElement {
    typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs

    private let makeOutputs: MakeViewOutputs

    init(makeOutputs: @escaping MakeViewOutputs) {
        self.makeOutputs = makeOutputs
    }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> ViewOutputs? {
        let viewOutputs: ViewOutputs? = makeViewOutputs(&startIndex, inputs, makeOutputs)
        if viewOutputs != nil {
            startIndex += 1
        }
        return viewOutputs
    }
}

//
//  UnaryViewElement.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

struct UnaryViewElement: ViewElement {
    private let makeOutputs: (ViewInputs) -> ViewOutputs

    init(makeOutputs: @escaping (ViewInputs) -> ViewOutputs) {
        self.makeOutputs = makeOutputs
    }

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> ViewOutputs? {
        makeViewOutputs(inputs, makeOutputs)
    }
}

//
//  ViewList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

protocol ViewList {
    typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs
    typealias MakeViewOutputsInterceptor = (
        _ inputs: ViewInputs, _ makeViewOutputs: MakeViewOutputs
    ) -> ViewOutputs?

    func makeViewOutputs(
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputsInterceptor
    ) -> [ViewOutputs]
}

extension ViewList {
    func makeViewOutputs(inputs: ViewInputs) -> [ViewOutputs] {
        makeViewOutputs(inputs: inputs) { inputs, makeViewOutputs in
            makeViewOutputs(inputs)
        }
    }
}

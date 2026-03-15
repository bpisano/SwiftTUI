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
        _ startIndex: inout Int,
        _ inputs: ViewInputs,
        _ makeViewOutputs: MakeViewOutputs
    ) -> ViewOutputs?

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputsInterceptor
    ) -> [ViewOutputs]
}

extension ViewList {
    func makeViewOutputs(inputs: ViewInputs) -> [ViewOutputs] {
        var index: Int = 0
        return makeViewOutputs(startIndex: &index, inputs: inputs) { index, inputs, makeViewOutputs in
            makeViewOutputs(inputs)
        }
    }
}

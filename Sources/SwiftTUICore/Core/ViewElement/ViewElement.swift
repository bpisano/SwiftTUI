//
//  ViewElement.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

protocol ViewElement {
    typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs
    typealias MakeViewOutputsInterceptor = (
        _ startIndex: inout Int,
        _ inputs: ViewInputs,
        _ makeViewOutputs: MakeViewOutputs
    ) -> ViewOutputs?

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> ViewOutputs?
}

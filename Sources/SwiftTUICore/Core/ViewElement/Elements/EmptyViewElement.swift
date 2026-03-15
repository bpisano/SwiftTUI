//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 15/03/2026.
//

import Foundation

struct EmptyViewElement: ViewElement {
    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> ViewOutputs? {
        nil
    }
}

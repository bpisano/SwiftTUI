//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 15/03/2026.
//

import Foundation

struct EmptyViewElement: ViewElement {
    let viewId: ViewId = ViewId(implicitId: -1)

    var retainedViewIds: [ViewId] { [] }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> ViewOutputs? {
        nil
    }
}

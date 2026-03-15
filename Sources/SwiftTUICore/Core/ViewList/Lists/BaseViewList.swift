//
//  BaseViewList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

struct BaseViewList: ViewList {
    private let elements: [any ViewElement]

    init(elements: [any ViewElement]) {
        self.elements = elements
    }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        withoutActuallyEscaping(makeViewOutputs) { escapingMakeViewOutputs in
            elements.compactMap { element in
                element.makeViewOutputs(startIndex: &startIndex, inputs: inputs) { index, inputs, makeViewOutputs in
                    escapingMakeViewOutputs(&index, inputs, makeViewOutputs)
                }
            }
        }
    }
}

extension BaseViewList: AttributeValueRepresentable {
    var attributeValueDescription: String {
        "BaseViewList with \(elements.count) elements"
    }
}

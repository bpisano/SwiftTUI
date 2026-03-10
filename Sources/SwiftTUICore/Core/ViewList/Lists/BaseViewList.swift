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
        inputs: ViewInputs,
        makeViewOutputs: MakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        withoutActuallyEscaping(makeViewOutputs) { escapingMakeViewOutputs in
            elements.compactMap { element in
                element.makeViewOutputs(inputs: inputs) { inputs, makeViewOutputs in
                    escapingMakeViewOutputs(inputs, makeViewOutputs)
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

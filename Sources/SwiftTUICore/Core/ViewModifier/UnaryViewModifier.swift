//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/03/2026.
//

import Foundation
import AttributeGraph

protocol UnaryViewModifier: ViewModifier {}

extension UnaryViewModifier {
    static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        makeViewListOutputs: @escaping MakeViewListOutputs
    ) -> ViewListOutputs {
        .unaryViewListOutputs("\(Self.self) ViewList", implicitId: inputs.implicitId) { inputs in
            Self.makeView(modifier, inputs: inputs) { modifiedInputs in
                let modifiedViewListInputs: ViewListInputs = .init(viewInputs: modifiedInputs)
                let childViewListOutputs: ViewListOutputs = makeViewListOutputs(modifiedViewListInputs)
                return childViewListOutputs.makeUnaryViewOutputs(inputs: modifiedInputs)
            }
        }
    }
}

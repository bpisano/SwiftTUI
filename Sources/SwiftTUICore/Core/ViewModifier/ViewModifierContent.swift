//
//  ViewModifierContent.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

public struct ViewModifierContent<Modifier: ViewModifier>: View, PrimitiveView { }

extension ViewModifierContent {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        var inputs: ViewInputs = inputs
        let outputsType = getOutputsType(inputs: &inputs)
        switch outputsType {
        case let .view(makeViewOutputs):
            return makeViewOutputs(inputs)
        case let .viewList(makeViewListOutputs):
            return .unaryViewOutputs(
                inputs: inputs,
                makeViewListOutputs: makeViewListOutputs
            )
        }
    }

    public static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        var inputs: ViewListInputs = inputs
        let outputsType = getOutputsType(inputs: &inputs)
        switch outputsType {
        case let .view(makeViewOutputs):
            return .unaryViewListOutputs { inputs in
                makeViewOutputs(inputs)
            }
        case let .viewList(makeViewListOutputs):
            return makeViewListOutputs(inputs)
        }
    }

    private static func getOutputsType<Inputs: InputStorage>(
        inputs: inout Inputs
    ) -> MakeViewOutputsInputStorageKey.OutputsType {
        guard let outputsType = inputs.popLast(MakeViewOutputsInputStorageKey.self) else {
            fatalError("Outputs type not found in inputs")
        }
        return outputsType
    }
}

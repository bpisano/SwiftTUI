//
//  ViewModifierContent.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation
import AttributeGraph

public struct ViewModifierContent<T: ViewModifier>: PrimitiveView {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        _ = view.wrappedValue

        var inputs: ViewInputs = inputs

        guard let body = inputs.popLast(BodyInput<Self>.self) else {
            return .init()
        }

        switch body {
        case let .view(makeViewBody):
            return makeViewBody(inputs)
        case let .list(makeViewListBody):
            return .multiView(inputs: inputs) { inputs in
                makeViewListBody(inputs)
            }
        }
    }

    public static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        var inputs: ViewListInputs = inputs

        guard let body = inputs.popLast(BodyInput<Self>.self) else {
            return .empty(inputs: inputs)
        }

        switch body {
        case let .view(makeViewBody):
            return .unaryViewList(inputs: inputs) { viewInputs in
                makeViewBody(viewInputs)
            }
        case let .list(makeViewListBody):
            return makeViewListBody(inputs)
        }
    }

    public static func viewListCount(inputs: ViewListCountInputs) -> Int? {
        var inputs: ViewListCountInputs = inputs

        guard let body = inputs.popLast(BodyCountInput<Self>.self) else {
            return nil
        }

        return body(inputs)
    }
}

extension ViewModifierContent: CustomStringConvertible {
    public var description: String {
        "\(T.self)"
    }
}

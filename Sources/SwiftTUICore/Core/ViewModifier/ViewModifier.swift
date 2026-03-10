//
//  ViewModifier.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

public protocol ViewModifier {
    associatedtype Body: View

    typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs
    typealias MakeViewListOutputs = (ViewListInputs) -> ViewListOutputs
    typealias Content = ViewModifierContent<Self>

    static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs

    static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        makeViewListOutputs: @escaping MakeViewListOutputs
    ) -> ViewListOutputs

    func body(content: Content) -> Body
}

extension ViewModifier {
    public static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        var inputs: ViewInputs = inputs
        inputs.append(.view(makeViewOutputs), to: MakeViewOutputsInputStorageKey.self)

        let modifiedBody = Attribute("\(Self.self) body") {
            let modifierContent: ViewModifierContent<Self> = .init()
            return modifier.wrappedValue.body(content: modifierContent)
        }

        return Body.makeView(modifiedBody, inputs: inputs)
    }

    public static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        makeViewListOutputs: @escaping MakeViewListOutputs
    ) -> ViewListOutputs {
        var inputs: ViewListInputs = inputs
        inputs.append(.viewList(makeViewListOutputs), to: MakeViewOutputsInputStorageKey.self)

        let modifiedBody = Attribute("\(Self.self) body") {
            let modifierContent: ViewModifierContent<Self> = .init()
            return modifier.wrappedValue.body(content: modifierContent)
        }

        return Body.makeViewList(modifiedBody, inputs: inputs)
    }
}

/// A ViewModifier that doesn't have a body.
protocol PrimitiveViewModifier: ViewModifier where Body == Never {}

extension PrimitiveViewModifier {
    func body(content: Content) -> Never {
        fatalError("PrimitiveViewModifier doesn't have a body")
    }
}

struct MakeViewOutputsInputStorageKey: ViewInputsStorageKey {
    typealias Value = OutputsType
}

extension MakeViewOutputsInputStorageKey {
    enum OutputsType {
        typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs
        typealias MakeViewListOutputs = (ViewListInputs) -> ViewListOutputs

        case view(MakeViewOutputs)
        case viewList(MakeViewListOutputs)
    }
}

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

    private static func getOutputsType<S: InputStorage>(
        inputs: inout S
    ) -> MakeViewOutputsInputStorageKey.OutputsType {
        guard let outputsType = inputs.popLast(MakeViewOutputsInputStorageKey.self) else {
            fatalError("Outputs type not found in inputs")
        }
        return outputsType
    }
}

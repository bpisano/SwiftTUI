//
//  ViewModifier.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import AttributeGraph
import Foundation

@MainActor
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
        inputs.append(.view(makeViewOutputs), to: MakeViewOutputsInputStorageKey.self)

        let modifiedBody = Attribute("\(Self.self) body") {
            let modifierContent: ViewModifierContent<Self> = .init()
            return modifier.wrappedValue.body(content: modifierContent)
        }

        modifier.updateDynamicProperties(environment: inputs.environment)

        return Body.makeView(modifiedBody, inputs: inputs)
    }

    public static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        makeViewListOutputs: @escaping MakeViewListOutputs
    ) -> ViewListOutputs {
        inputs.append(.viewList(makeViewListOutputs), to: MakeViewOutputsInputStorageKey.self)

        let modifiedBody = Attribute("\(Self.self) body") {
            let modifierContent: ViewModifierContent<Self> = .init()
            return modifier.wrappedValue.body(content: modifierContent)
        }

        modifier.updateDynamicProperties(environment: inputs.environment)

        return Body.makeViewList(modifiedBody, inputs: inputs)
    }
}

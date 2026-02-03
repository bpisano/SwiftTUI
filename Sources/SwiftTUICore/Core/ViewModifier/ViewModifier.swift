//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import AttributeGraph
import Foundation

protocol ViewModifier {
    associatedtype Body: View

    typealias Content = ViewModifierContent<Self>

    static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        body: @escaping (ViewInputs) -> ViewOutputs
    ) -> ViewOutputs

    static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        body: @escaping (ViewListInputs) -> ViewListOutputs
    ) -> ViewListOutputs

    static func viewListCount(
        inputs: ViewListCountInputs,
        body: (ViewListCountInputs) -> Int?
    ) -> Int?

    @ViewBuilder
    func body(content: Content) -> Body
}

extension ViewModifier {
    static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        body: @escaping (ViewInputs) -> ViewOutputs
    ) -> ViewOutputs {
        var inputs: ViewInputs = inputs
        inputs.append(.view(body), to: BodyInput<Content>.self)

        let modifierBody = Attribute {
            modifier.updateDynamicProperties()
            return modifier.wrappedValue.body(content: .init())
        }
        modifierBody.label = "\(Self.self) body"

        return Body.makeView(modifierBody, inputs: inputs)
    }

    static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        body: @escaping (ViewListInputs) -> ViewListOutputs
    ) -> ViewListOutputs {
        var inputs: ViewListInputs = inputs
        inputs.append(.list(body), to: BodyInput<Content>.self)

        let modifierBody = Attribute {
            modifier.wrappedValue.body(content: .init())
        }
        modifierBody.label = "\(Self.self) body"

        return Body.makeViewList(modifierBody, inputs: inputs)
    }

    static func viewListCount(
        inputs: ViewListCountInputs,
        body: (ViewListCountInputs) -> Int?
    ) -> Int? {
        var inputs: ViewListCountInputs = inputs

        withoutActuallyEscaping(body) { escapingBody in
            inputs.append(escapingBody, to: BodyCountInput<Content>.self)
        }

        return Body.viewListCount(inputs: inputs)
    }
}

extension View {
    func modifier<M: ViewModifier>(_ modifier: M) -> ModifiedContent<Self, M> {
        ModifiedContent(self, modifier: modifier)
    }
}

//
//  ModifiedView.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

struct ModifiedView<Content: View, Modifier: ViewModifier>: View, PrimitiveView {
    private let content: Content
    private let modifier: Modifier

    init(
        content: Content,
        modifier: Modifier
    ) {
        self.content = content
        self.modifier = modifier
    }
}

extension ModifiedView {
    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let content: Attribute<Content> = view.map(\.content)
        let modifier: Attribute<Modifier> = view.map(\.modifier)

        content.label = "\(Content.self)"
        modifier.label = "\(Modifier.self)"

        return Modifier.makeView(modifier, inputs: inputs) { modifiedInputs in
            Content.makeView(content, inputs: modifiedInputs)
        }
    }

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let content: Attribute<Content> = view.map(\.content)
        let modifier: Attribute<Modifier> = view.map(\.modifier)

        content.label = "\(Content.self)"
        modifier.label = "\(Modifier.self)"

        return Modifier.makeViewList(modifier, inputs: inputs) { modifiedInputs in
            Content.makeViewList(content, inputs: modifiedInputs)
        }
    }
}

extension ModifiedView: AttributeValueRepresentable {
    var attributeValueDescription: String {
        "ModifiedView"
    }
}

extension View {
    public func modifier<M: ViewModifier>(_ modifier: M) -> some View {
        ModifiedView(content: self, modifier: modifier)
    }
}

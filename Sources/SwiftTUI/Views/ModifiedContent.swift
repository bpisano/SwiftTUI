//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation
import AttributeGraph

struct ModifiedContent<Content: View, Modifier: ViewModifier>: View {
    private let content: Content
    private let modifier: Modifier

    init(
        _ content: Content,
        modifier: Modifier
    ) {
        self.content = content
        self.modifier = modifier
    }
}

extension ModifiedContent {
    static func makeView(
        _ view: Attribute<ModifiedContent<Content, Modifier>>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        @Attribute var content = view.wrappedValue.content
        @Attribute var modifier = view.wrappedValue.modifier

        $content.label = "\(Content.self)"
        $modifier.label = "\(Modifier.self)"

        return Modifier.makeView($modifier, inputs: inputs) { modifiedInputs in
            Content.makeView($content, inputs: modifiedInputs)
        }
    }

    static func makeViewList(
        _ view: Attribute<ModifiedContent<Content, Modifier>>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        @Attribute var content = view.wrappedValue.content
        @Attribute var modifier = view.wrappedValue.modifier

        $content.label = "\(Content.self)"
        $modifier.label = "\(Modifier.self)"

        return Modifier.makeViewList($modifier, inputs: inputs) { modifiedInputs in
            Content.makeViewList($content, inputs: modifiedInputs)
        }
    }

    static func viewListCount(
        inputs: ViewListCountInputs
    ) -> Int? {
        Modifier.viewListCount(inputs: inputs) { modifiedInputs in
            Content.viewListCount(inputs: modifiedInputs)
        }
    }
}

extension ModifiedContent: CustomStringConvertible {
    var description: String {
        "ModifiedContent"
    }
}

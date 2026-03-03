//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 23/02/2026.
//

import Foundation
import AttributeGraph

struct IDView<Content: View, ID: Hashable>: PrimitiveView {
    let content: Content
    let id: ID

    init(
        _ content: Content,
        id: ID
    ) {
        self.content = content
        self.id = id
    }
}

extension IDView {
    static func makeView(
        _ view: Attribute<IDView<Content, ID>>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let explicitId: ViewId.Explicit = .init(id: view.wrappedValue.id)

        var modifiedInputs: ViewInputs = inputs
        modifiedInputs.append([explicitId], to: ExplicitIdInput.self)
        defer { _ = modifiedInputs.popLast(ExplicitIdInput.self) }

        let content = view.map(\.content)
        content.label = "\(Content.self)"

        return Content.makeView(content, inputs: modifiedInputs)
    }

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let content = view.map(\.content)
        content.label = "\(Content.self)"

        let childOutputs: ViewListOutputs = Content.makeViewList(
            content,
            inputs: inputs
        )
        let view = view.wrappedValue
        let base = childOutputs.makeViewList()
        let explicit = ViewId.Explicit(id: view.id)
        let idBoundViewList: Attribute<any ViewList> = Attribute {
            IDBoundViewList(
                base: base,
                explicit: explicit
            )
        }

        return .dynamicList(
            idBoundViewList,
            inputs: inputs,
            count: Content.viewListCount(inputs: .init())
        )
    }

    static func viewListCount(inputs: ViewListCountInputs) -> Int? {
        Content.viewListCount(inputs: inputs)
    }
}

extension View {
    public func id<ID: Hashable>(_ id: ID) -> some View {
        IDView(self, id: id)
    }
}

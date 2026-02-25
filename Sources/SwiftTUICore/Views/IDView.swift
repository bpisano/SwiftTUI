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
    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let explicitId: ViewId.Explicit = .init(id: view.wrappedValue.id)

        var modifiedInputs: ViewListInputs = inputs
        modifiedInputs.append(explicitId, to: ExplicitIdInput.self)
        defer {
            _ = modifiedInputs.popLast(ExplicitIdInput.self)
        }

        let childOutputs: ViewListOutputs = Content.makeViewList(
            view.map(\.content),
            inputs: modifiedInputs
        )

        let viewList: Attribute<ViewList> = Attribute {
            let view = view.wrappedValue
            let base = childOutputs.makeViewList()
            let explicit = ViewId.Explicit(id: view.id)
            return IDBoundViewList(
                base: base,
                explicit: explicit
            )
        }

        return .dynamicList(
            viewList,
            inputs: inputs,
            count: childOutputs.count
        )
    }
}

extension View {
    public func id<ID: Hashable>(_ id: ID) -> some View {
        IDView(self, id: id)
    }
}

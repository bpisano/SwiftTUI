//
//  IDView.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 06/06/2026.
//

import Foundation
import AttributeGraph

struct IDView<Content: View>: View, PrimitiveView {
    let content: Content
    let id: AnyHashable

    init(
        content: Content,
        id: AnyHashable
    ) {
        self.content = content
        self.id = id
    }
}

extension IDView: DynamicView {
    var dynamicBranchId: AnyHashable { id }

    static func makeDynamicChildView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        Content.makeView(child(of: view), inputs: inputs)
    }

    static func makeDynamicChildViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        Content.makeViewList(child(of: view), inputs: inputs)
    }

    private static func child(of view: Attribute<Self>) -> Attribute<Content> {
        let snapshot: Self = view.wrappedValue
        let expectedId: AnyHashable = snapshot.id
        return .init(
            "\(Content.self)",
            rule: DynamicChildRule(parent: view, initialValue: snapshot.content) { current in
                current.id == expectedId ? current.content : nil
            }
        )
    }
}

extension View {
    /// Binds this view to an explicit identity.
    ///
    /// - Parameter id: A value that uniquely identifies this view's content.
    /// - Returns: A view bound to the given identity.
    public func id<ID: Hashable>(_ id: ID) -> some View {
        IDView(content: self, id: AnyHashable(id))
    }
}

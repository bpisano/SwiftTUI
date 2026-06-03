//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 15/03/2026.
//

import Foundation
import AttributeGraph

/// A view that draws nothing and takes up no space.
///
/// Use an empty view where a ``View`` is required but no content should appear,
/// such as a branch of a conditional that renders nothing.
public struct EmptyView: View, PrimitiveView {
    /// Creates an empty view.
    public init() {}
}

extension EmptyView {
    public static func makeView(
        _ view: Attribute<EmptyView>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let layoutComputer = Attribute("EmptyView LayoutComputer") {
            LayoutComputer { _ in
                return .zero
            } viewGeometries: { _ in
                []
            }
        }

        let displayList = Attribute("EmptyView DisplayList") {
            return DisplayList([])
        }

        return ViewOutputs(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    public static func makeViewList(
        _ view: Attribute<EmptyView>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .empty()
    }
}

extension EmptyView: @MainActor AttributeValueRepresentable {
    public var attributeValueDescription: String {
        "EmptyView"
    }
}

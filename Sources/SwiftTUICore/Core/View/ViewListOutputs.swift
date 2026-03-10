//
//  ViewListOutputs.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

public struct ViewListOutputs {
    let viewList: Attribute<any ViewList>

    init(viewList: Attribute<any ViewList>) {
        self.viewList = viewList
    }
}

extension ViewListOutputs {
    /// Creates a `ViewListOutputs` from a closure that can generate a single view's outputs.
    ///
    /// - Parameters:
    ///   - label: An optional label for the view list attribute. Defaults to "ViewList".
    ///   - makeViewOutputs: A closure that takes `ViewInputs` and returns `ViewOutputs` for the unary view list.
    ///   - Returns: A `ViewListOutputs` instance containing the unary view list.
    static func unaryViewListOutputs(
        _ label: String = "ViewList",
        makeViewOutputs: @escaping (ViewInputs) -> ViewOutputs
    ) -> ViewListOutputs {
        let unaryViewElement: UnaryViewElement = .init(makeOutputs: makeViewOutputs)
        let viewList: Attribute<any ViewList> = Attribute(label) {
            BaseViewList(elements: [unaryViewElement])
        }
        return .init(viewList: viewList)
    }
}

extension ViewListOutputs: AttributeValueRepresentable {
    public var attributeValueDescription: String {
        "ViewListOutputs"
    }
}

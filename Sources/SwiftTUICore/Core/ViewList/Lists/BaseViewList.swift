//
//  BaseViewList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

struct BaseViewList: ViewList {
    private let elements: [any ViewElement]

    init(elements: [any ViewElement]) {
        self.elements = elements
    }

    var viewIds: [ViewId]? { elements.flatMap(\.retainedViewIds) }

    func applyItems(_ body: (RetainedViewListItem) -> Void) {
        for element in elements {
            guard let item = element.retainedViewListItem() else { continue }
            body(item)
        }
    }
}

extension BaseViewList: AttributeValueRepresentable {
    var attributeValueDescription: String {
        "BaseViewList with \(elements.count) elements"
    }
}

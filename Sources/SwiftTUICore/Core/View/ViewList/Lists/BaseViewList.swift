//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 01/12/2025.
//

import Foundation

struct BaseViewList: ViewList {
    var count: Int { elements.count }
    var viewIds: ViewId.Views? {
        ImplicitViewIds(
            implicitId: implicitId,
            explicit: explicitId,
            count: elements.count
        )
    }

    private let elements: any ViewListElements
    private let implicitId: Int
    private let explicitId: ViewId.Explicit?

    init(
        elements: any ViewListElements,
        implicitId: Int,
        explicitId: ViewId.Explicit?
    ) {
        self.elements = elements
        self.implicitId = implicitId
        self.explicitId = explicitId
    }

    func makeViews(
        from start: inout Int,
        inputs: ViewInputs,
        body: Body
    ) {
        withoutActuallyEscaping(body) { escapingBody in
            _ = elements.makeElements(from: &start, inputs: inputs, body: escapingBody)
        }
    }
}

extension BaseViewList: CustomStringConvertible {
    var description: String {
        "BaseViewList(elements: \(elements), implicitId: \(implicitId), explicitId: \(explicitId?.id, default: "nil"))"
    }
}

//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry

struct LayoutComputer {
    private let sizeThatFits: (_ proposal: ProposedViewSize) -> Size
    private let childGeometries: (Rect) -> [ViewGeometry]

    init(
        sizeThatFits: @escaping (_ proposal: ProposedViewSize) -> Size,
        childGeometries: @escaping (_ rect: Rect) -> [ViewGeometry]
    ) {
        self.sizeThatFits = sizeThatFits
        self.childGeometries = childGeometries
    }

    func sizeThatFits(_ proposal: ProposedViewSize) -> Size {
        sizeThatFits(proposal)
    }

    func childGeometries(in rect: Rect) -> [ViewGeometry] {
        childGeometries(rect)
    }
}

extension LayoutComputer: CustomStringConvertible {
    var description: String {
        "LayoutComputer"
    }
}

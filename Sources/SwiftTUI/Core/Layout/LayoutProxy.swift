//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 25/11/2025.
//

import Foundation
import Geometry

struct LayoutProxy {
    private let layoutComputer: LayoutComputer
    private let place: (Rect, ProposedViewSize) -> Void

    init(
        layoutComputer: LayoutComputer,
        place: @escaping (_ rect: Rect, _ proposal: ProposedViewSize) -> Void
    ) {
        self.layoutComputer = layoutComputer
        self.place = place
    }

    func size(in proposal: ProposedViewSize) -> Size {
        layoutComputer.sizeThatFits(proposal)
    }

    func place(in rect: Rect, proposal: ProposedViewSize) {
        place(rect, proposal)
    }
}

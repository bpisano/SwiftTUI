//
//  LayoutProxy.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

public struct LayoutProxy {
    private let layoutComputer: LayoutComputer
    private let place: (Rect) -> Void

    init(
        layoutComputer: LayoutComputer,
        place: @escaping (_ rect: Rect) -> Void
    ) {
        self.layoutComputer = layoutComputer
        self.place = place
    }

    func size(in proposal: ProposedViewSize) -> Size {
        layoutComputer.sizeThatFits(proposal)
    }

    func place(in rect: Rect) {
        place(rect)
    }
}

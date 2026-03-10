//
//  FrameLayout.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

struct FrameLayout: Layout {
    let width: GeometryUnit?
    let height: GeometryUnit?

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> Size {
        let proposedSize: ProposedViewSize = .init(
            width: width ?? proposal.width,
            height: height ?? proposal.height
        )
        return subviews.first?.size(in: proposedSize) ?? .zero
    }

    func placeSubviews(
        in bounds: Rect,
        subviews: [LayoutProxy]
    ) {
        for subview in subviews {
            let proposedSize: ProposedViewSize = .init(
                width: width ?? bounds.width,
                height: height ?? bounds.height
            )
            let subviewSize: Size = subview.size(in: proposedSize)
            let placementFrame: Rect = .init(
                origin: bounds.origin,
                size: subviewSize
            )
            subview.place(in: placementFrame)
        }
    }
}

//
//  RootLayout.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 17/03/2026.
//

import Foundation
import Geometry

public struct RootLayout: Layout {
    public init() {}

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview],
        cache: inout Void
    ) -> Size {
        // RootLayout takes all available space
        proposal.replacingUnspecifiedDimensions()
    }

    public func placeSubviews(
        in bounds: Rect,
        subviews: [Subview],
        cache: inout Void
    ) {
        guard !subviews.isEmpty else { return }

        // Constrain all children to the bounds size
        let proposal = ProposedViewSize(width: bounds.width, height: bounds.height)

        // Get sizes for all children with bounds constraint
        let childSizes = subviews.map { $0.size(in: proposal) }

        // Calculate total stack height
        let totalHeight = childSizes.reduce(0) { $0 + $1.height }

        // Calculate vertical centering offset for the entire stack
        let verticalOffset = (bounds.height - totalHeight) / 2

        // Place each child centered horizontally and stacked vertically
        var y = bounds.minY + verticalOffset
        for (index, subview) in subviews.enumerated() {
            let childSize = childSizes[index]

            // Calculate horizontal centering offset
            let x = bounds.minX + (bounds.width - childSize.width) / 2

            subview.place(in: Rect(
                origin: Point(x: x, y: y),
                size: childSize
            ))

            y += childSize.height
        }
    }
}

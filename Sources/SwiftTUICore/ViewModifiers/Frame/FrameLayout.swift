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
    let alignment: Alignment

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> Size {
        guard let subview = subviews.first else { return .zero }

        // Propose frame constraints to child
        let childSize = subview.size(in: ProposedViewSize(width: width, height: height))

        // Frame size is specified dimensions, or child size if unspecified
        return Size(
            width: width ?? childSize.width,
            height: height ?? childSize.height
        )
    }

    func placeSubviews(
        in bounds: Rect,
        subviews: [LayoutProxy]
    ) {
        guard let subview = subviews.first else { return }

        // Get child size with frame constraints
        let childSize = subview.size(in: ProposedViewSize(width: width, height: height))

        // Frame dimensions (specified or fill bounds)
        let frameWidth = width ?? bounds.width
        let frameHeight = height ?? bounds.height

        // Calculate position based on alignment within the frame
        let x =
            bounds.minX
            + alignmentOffset(
                childValue: childSize.width,
                containerValue: frameWidth,
                alignment: alignment.horizontal,
                hasConstraint: width != nil
            )

        let y =
            bounds.minY
            + alignmentOffset(
                childValue: childSize.height,
                containerValue: frameHeight,
                alignment: alignment.vertical,
                hasConstraint: height != nil
            )

        subview.place(in: Rect(origin: Point(x: x, y: y), size: childSize))
    }

    /// Calculate alignment offset for horizontal axis
    private func alignmentOffset(
        childValue: GeometryUnit,
        containerValue: GeometryUnit,
        alignment: HorizontalAlignment,
        hasConstraint: Bool
    ) -> GeometryUnit {
        guard hasConstraint else { return 0 }

        let childDimensions = ViewDimensions(size: Size(width: childValue, height: 0))
        let containerDimensions = ViewDimensions(size: Size(width: containerValue, height: 0))

        return alignment.key.id.defaultValue(in: containerDimensions)
            - alignment.key.id.defaultValue(in: childDimensions)
    }

    /// Calculate alignment offset for vertical axis
    private func alignmentOffset(
        childValue: GeometryUnit,
        containerValue: GeometryUnit,
        alignment: VerticalAlignment,
        hasConstraint: Bool
    ) -> GeometryUnit {
        guard hasConstraint else { return 0 }

        let childDimensions = ViewDimensions(size: Size(width: 0, height: childValue))
        let containerDimensions = ViewDimensions(size: Size(width: 0, height: containerValue))

        return alignment.key.id.defaultValue(in: containerDimensions)
            - alignment.key.id.defaultValue(in: childDimensions)
    }
}

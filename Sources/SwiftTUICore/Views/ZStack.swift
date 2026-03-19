//
//  ZStack.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 19/03/2026.
//

import Foundation
import Geometry

public struct ZStack: Layout {
    private let alignment: Alignment

    public init(alignment: Alignment = .center) {
        self.alignment = alignment
    }
}

extension ZStack {
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview]
    ) -> Size {
        guard !subviews.isEmpty else {
            return .zero
        }

        // Get the size of each subview
        let sizes = subviews.map { subview in
            subview.size(in: proposal)
        }

        // ZStack sizes to the maximum dimensions
        let maxWidth = sizes.map { $0.width }.max() ?? 0
        let maxHeight = sizes.map { $0.height }.max() ?? 0

        return Size(width: maxWidth, height: maxHeight)
    }

    public func placeSubviews(
        in bounds: Rect,
        subviews: [Subview]
    ) {
        guard !subviews.isEmpty else { return }

        // Place all subviews at the same location, aligned within bounds
        for subview in subviews {
            let subviewSize = subview.size(in: ProposedViewSize(bounds.size))

            // Calculate position based on alignment
            let x =
                bounds.minX
                + alignmentOffset(
                    childValue: subviewSize.width,
                    containerValue: bounds.width,
                    alignment: alignment.horizontal
                )

            let y =
                bounds.minY
                + alignmentOffset(
                    childValue: subviewSize.height,
                    containerValue: bounds.height,
                    alignment: alignment.vertical
                )

            let frame = Rect(
                origin: Point(x: x, y: y),
                size: subviewSize
            )

            subview.place(in: frame)
        }
    }

    /// Calculate alignment offset for horizontal axis
    private func alignmentOffset(
        childValue: GeometryUnit,
        containerValue: GeometryUnit,
        alignment: HorizontalAlignment
    ) -> GeometryUnit {
        let childDimensions = ViewDimensions(size: Size(width: childValue, height: 0))
        let containerDimensions = ViewDimensions(size: Size(width: containerValue, height: 0))

        return alignment.key.id.defaultValue(in: containerDimensions)
            - alignment.key.id.defaultValue(in: childDimensions)
    }

    /// Calculate alignment offset for vertical axis
    private func alignmentOffset(
        childValue: GeometryUnit,
        containerValue: GeometryUnit,
        alignment: VerticalAlignment
    ) -> GeometryUnit {
        let childDimensions = ViewDimensions(size: Size(width: 0, height: childValue))
        let containerDimensions = ViewDimensions(size: Size(width: 0, height: containerValue))

        return alignment.key.id.defaultValue(in: containerDimensions)
            - alignment.key.id.defaultValue(in: childDimensions)
    }
}

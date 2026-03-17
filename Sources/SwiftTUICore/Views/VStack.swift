//
//  VStack.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

public struct VStack: Layout {
    private let alignment: HorizontalAlignment
    private let spacing: GeometryUnit

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: GeometryUnit = 0
    ) {
        self.alignment = alignment
        self.spacing = spacing
    }
}

extension VStack {
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview]
    ) -> Size {
        guard !subviews.isEmpty else { return .zero }

        let containerWidth = proposal.width ?? 10
        let layout = calculateLayout(
            subviews: subviews, width: containerWidth, availableHeight: proposal.height)

        return Size(
            width: layout.maxWidth,
            height: layout.totalHeight
        )
    }

    public func placeSubviews(
        in bounds: Rect,
        subviews: [Subview]
    ) {
        guard !subviews.isEmpty else { return }

        let layout = calculateLayout(
            subviews: subviews, width: bounds.width, availableHeight: bounds.height)

        var y = bounds.minY
        for (index, subview) in subviews.enumerated() {
            let itemLayout = layout.items[index]

            // Calculate x position based on horizontal alignment
            let x =
                bounds.minX
                + alignmentOffset(
                    childWidth: itemLayout.size.width,
                    containerWidth: bounds.width
                )

            subview.place(
                in: Rect(
                    origin: Point(x: x, y: y),
                    size: itemLayout.size
                ))

            y += itemLayout.size.height
            if index < subviews.count - 1 {
                y += spacing
            }
        }
    }

    /// Calculate horizontal offset based on alignment
    private func alignmentOffset(childWidth: GeometryUnit, containerWidth: GeometryUnit)
        -> GeometryUnit
    {
        let childDimensions = ViewDimensions(size: Size(width: childWidth, height: 0))
        let containerDimensions = ViewDimensions(size: Size(width: containerWidth, height: 0))

        return alignment.key.id.defaultValue(in: containerDimensions)
            - alignment.key.id.defaultValue(in: childDimensions)
    }

    /// Calculate the layout for all children
    private func calculateLayout(
        subviews: [Subview],
        width: GeometryUnit,
        availableHeight: GeometryUnit?
    ) -> StackLayout {
        // Determine which views are flexible
        let viewInfo = subviews.map { subview -> ViewInfo in
            let naturalSize = subview.size(in: ProposedViewSize(width: width, height: nil))
            let expandedSize = subview.size(in: ProposedViewSize(width: width, height: .infinity))
            let isFlexible =
                expandedSize.height.isInfinite || expandedSize.height > naturalSize.height + 0.001

            return ViewInfo(
                isFlexible: isFlexible,
                naturalSize: naturalSize,
                minimumHeight: isFlexible ? 0 : naturalSize.height
            )
        }

        // Calculate space distribution
        let totalSpacing = spacing * GeometryUnit(max(0, subviews.count - 1))
        let minimumHeight = viewInfo.reduce(0) { $0 + $1.minimumHeight } + totalSpacing
        let flexibleCount = viewInfo.filter { $0.isFlexible }.count

        // Determine final height
        let finalHeight: GeometryUnit
        if flexibleCount > 0, let availableHeight, availableHeight.isFinite {
            finalHeight = max(minimumHeight, availableHeight)
        } else {
            finalHeight = minimumHeight
        }

        // Distribute extra space to flexible views
        let extraSpace = max(0, finalHeight - minimumHeight)
        let extraPerFlexible = flexibleCount > 0 ? extraSpace / GeometryUnit(flexibleCount) : 0

        // Calculate final sizes
        let items = zip(subviews, viewInfo).map { subview, info -> ItemLayout in
            let height = info.minimumHeight + (info.isFlexible ? extraPerFlexible : 0)
            let size = subview.size(in: ProposedViewSize(width: width, height: height))
            return ItemLayout(size: size)
        }

        let maxWidth = items.map { $0.size.width }.max() ?? 0

        return StackLayout(
            items: items,
            totalHeight: finalHeight,
            maxWidth: maxWidth
        )
    }
}

// MARK: - Helper Types

private struct ViewInfo {
    let isFlexible: Bool
    let naturalSize: Size
    let minimumHeight: GeometryUnit
}

private struct ItemLayout {
    let size: Size
}

private struct StackLayout {
    let items: [ItemLayout]
    let totalHeight: GeometryUnit
    let maxWidth: GeometryUnit
}

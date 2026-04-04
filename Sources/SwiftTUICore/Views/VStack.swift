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
    public struct Cache {
        fileprivate var layout: StackLayout?
    }

    public func makeCache(subviews: [Subview]) -> Cache {
        Cache()
    }

    public func updateCache(_ cache: inout Cache, subviews: [Subview]) {
        cache.layout = nil
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview],
        cache: inout Cache
    ) -> Size {
        guard !subviews.isEmpty else { return .zero }

        let containerWidth = proposal.width ?? 10
        let layout = calculateLayout(
            subviews: subviews, width: containerWidth, availableHeight: proposal.height)
        cache.layout = layout

        return Size(
            width: layout.maxWidth,
            height: layout.totalHeight
        )
    }

    public func placeSubviews(
        in bounds: Rect,
        subviews: [Subview],
        cache: inout Cache
    ) {
        guard !subviews.isEmpty else { return }

        let layout = cache.layout ?? calculateLayout(
            subviews: subviews, width: bounds.width, availableHeight: bounds.height)

        var y = bounds.minY
        for (index, subview) in subviews.enumerated() {
            let itemLayout = layout.items[index]

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

    private func calculateLayout(
        subviews: [Subview],
        width: GeometryUnit,
        availableHeight: GeometryUnit?
    ) -> StackLayout {
        let count = subviews.count

        // Pre-allocate both output arrays up front — one allocation each
        // instead of building intermediate arrays with chained .map calls.
        struct MeasuredView {
            var naturalSize: Size
            var isFlexible: Bool
        }
        var measured = [MeasuredView](
            repeating: MeasuredView(naturalSize: .zero, isFlexible: false),
            count: count
        )
        var items = [ItemLayout](repeating: ItemLayout(size: .zero), count: count)

        // --- Pass 1: natural + expanded measurement, inline accumulation ---
        // Accumulate flexibleCount and minimumHeight in-loop — no separate
        // filter { }.count or reduce passes, and no temporary arrays.
        var minimumHeight: GeometryUnit = spacing * GeometryUnit(max(0, count - 1))
        var flexibleCount: Int = 0

        for i in 0..<count {
            let natural = subviews[i].size(in: ProposedViewSize(width: width, height: nil))
            let expandedHeight = subviews[i].size(
                in: ProposedViewSize(width: width, height: .infinity)
            ).height
            let isFlexible = expandedHeight.isInfinite || expandedHeight > natural.height + 0.001

            measured[i] = MeasuredView(naturalSize: natural, isFlexible: isFlexible)

            if isFlexible {
                flexibleCount += 1
            } else {
                minimumHeight += natural.height
            }
        }

        // --- Height distribution ---
        let finalHeight: GeometryUnit
        if flexibleCount > 0, let h = availableHeight, h.isFinite {
            finalHeight = max(minimumHeight, h)
        } else {
            finalHeight = minimumHeight
        }
        let extraPerFlexible: GeometryUnit =
            flexibleCount > 0
            ? max(0, finalHeight - minimumHeight) / GeometryUnit(flexibleCount)
            : 0

        // --- Pass 2: final sizes + inline maxWidth tracking ---
        // Non-flexible children reuse naturalSize — their size doesn't change
        // with the proposed height, so the 3rd size() call is unnecessary.
        // This reduces total size() calls from 3n → 2n (all-fixed) or 2n+k (mixed).
        var maxWidth: GeometryUnit = 0
        for i in 0..<count {
            let m = measured[i]
            let size: Size
            if m.isFlexible {
                size = subviews[i].size(in: ProposedViewSize(width: width, height: extraPerFlexible))
            } else {
                size = m.naturalSize
            }
            items[i] = ItemLayout(size: size)
            if size.width > maxWidth { maxWidth = size.width }
        }

        return StackLayout(items: items, totalHeight: finalHeight, maxWidth: maxWidth)
    }
}

// MARK: - Helper Types

private struct ItemLayout {
    let size: Size
}

private struct StackLayout {
    let items: [ItemLayout]
    let totalHeight: GeometryUnit
    let maxWidth: GeometryUnit
}

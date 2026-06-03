//
//  HStack.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/03/2026.
//

import Foundation
import Geometry

/// A layout that arranges its subviews in a horizontal row.
///
/// Each subview is measured at its natural width; remaining space is divided
/// among flexible subviews. The `alignment` controls how subviews of differing
/// heights line up on the vertical axis.
///
/// ```swift
/// HStack(spacing: 1) {
///     Text("Left")
///     Text("Right")
/// }
/// ```
public struct HStack: Layout {
    private let alignment: VerticalAlignment
    private let spacing: GeometryUnit

    /// Creates a horizontal stack with the given alignment and spacing.
    ///
    /// - Parameters:
    ///   - alignment: The vertical alignment of subviews within the row.
    ///     Defaults to `.center`.
    ///   - spacing: The number of cells between adjacent subviews. Defaults to `0`.
    public init(
        alignment: VerticalAlignment = .center,
        spacing: GeometryUnit = 0
    ) {
        self.alignment = alignment
        self.spacing = spacing
    }
}

extension HStack {
    private static let flexibleWidthProbe: GeometryUnit = 10_000

    public struct Cache {
        // Most recently computed layout — consumed by placeSubviews.
        fileprivate var activeLayout: StackLayout?
        // Two-slot LRU: avoids recomputing sizeThatFits for proposals already seen
        // this pass (e.g. natural probe + allocated-width pass from a parent stack).
        // Cuts exponential blowup in nested flexible stacks to O(unique proposals × n).
        fileprivate var slot0: (proposal: ProposedViewSize, layout: StackLayout)?
        fileprivate var slot1: (proposal: ProposedViewSize, layout: StackLayout)?
    }

    public func makeCache(subviews: [Subview]) -> Cache {
        Cache()
    }

    public func updateCache(_ cache: inout Cache, subviews: [Subview]) {
        cache.activeLayout = nil
        cache.slot0 = nil
        cache.slot1 = nil
    }

    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview],
        cache: inout Cache
    ) -> Size {
        guard !subviews.isEmpty else { return .zero }

        // Slot 0 hit (most-recent proposal)
        if let s = cache.slot0, s.proposal == proposal {
            cache.activeLayout = s.layout
            return Size(width: s.layout.totalWidth, height: s.layout.maxHeight)
        }
        // Slot 1 hit — promote to slot 0 (LRU eviction)
        if let s = cache.slot1, s.proposal == proposal {
            cache.slot1 = cache.slot0
            cache.slot0 = s
            cache.activeLayout = s.layout
            return Size(width: s.layout.totalWidth, height: s.layout.maxHeight)
        }

        // Miss: compute, store in slot 0, evict slot 0 → slot 1
        // Pass proposal.height through verbatim (including nil). A nil height means
        // "unspecified — report natural size": children must receive nil so they
        // measure naturally. Substituting a magic number here makes tall children
        // under-report at natural height, which a parent VStack then misreads as
        // vertical flexibility.
        let layout = calculateLayout(
            subviews: subviews,
            height: proposal.height,
            availableWidth: proposal.width
        )
        cache.slot1 = cache.slot0
        cache.slot0 = (proposal, layout)
        cache.activeLayout = layout

        return Size(width: layout.totalWidth, height: layout.maxHeight)
    }

    public func placeSubviews(
        in bounds: Rect,
        subviews: [Subview],
        cache: inout Cache
    ) {
        guard !subviews.isEmpty else { return }

        let layout = cache.activeLayout ?? calculateLayout(
            subviews: subviews,
            height: bounds.height,
            availableWidth: bounds.width
        )

        var x = bounds.minX
        for (index, subview) in subviews.enumerated() {
            let itemLayout = layout.items[index]
            let y =
                bounds.minY
                + alignmentOffset(
                    childHeight: itemLayout.size.height,
                    containerHeight: bounds.height
                )

            subview.place(
                in: Rect(
                    origin: Point(x: x, y: y),
                    size: itemLayout.size
                )
            )

            x += itemLayout.size.width
            if index < subviews.count - 1 {
                x += spacing
            }
        }
    }

    private func alignmentOffset(
        childHeight: GeometryUnit,
        containerHeight: GeometryUnit
    ) -> GeometryUnit {
        let childDimensions = ViewDimensions(size: Size(width: 0, height: childHeight))
        let containerDimensions = ViewDimensions(size: Size(width: 0, height: containerHeight))

        return alignment.key.id.defaultValue(in: containerDimensions)
            - alignment.key.id.defaultValue(in: childDimensions)
    }

    private func calculateLayout(
        subviews: [Subview],
        height: GeometryUnit?,
        availableWidth: GeometryUnit?
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
        // Accumulate flexibleCount and minimumWidth in-loop — no separate
        // filter { }.count or reduce passes, and no temporary arrays.
        var minimumWidth: GeometryUnit = spacing * GeometryUnit(max(0, count - 1))
        var flexibleCount: Int = 0

        for i in 0..<count {
            let natural = subviews[i].size(in: ProposedViewSize(width: nil, height: height))
            let expandedWidth = subviews[i].size(
                in: ProposedViewSize(width: Self.flexibleWidthProbe, height: height)
            ).width
            let isFlexible = expandedWidth.isInfinite || expandedWidth > natural.width + 0.001

            measured[i] = MeasuredView(naturalSize: natural, isFlexible: isFlexible)

            if isFlexible {
                flexibleCount += 1
            } else {
                minimumWidth += natural.width
            }
        }

        // --- Width distribution ---
        let finalWidth: GeometryUnit
        if flexibleCount > 0, let w = availableWidth, w.isFinite {
            finalWidth = max(minimumWidth, w)
        } else {
            finalWidth = minimumWidth
        }
        let extraPerFlexible: GeometryUnit =
            flexibleCount > 0
            ? max(0, finalWidth - minimumWidth) / GeometryUnit(flexibleCount)
            : 0

        // --- Pass 2: final sizes + inline maxHeight tracking ---
        // Non-flexible children reuse naturalSize — their size doesn't change
        // with the proposed width, so the 3rd size() call is unnecessary.
        // This reduces total size() calls from 3n → 2n (all-fixed) or 2n+k (mixed).
        var maxHeight: GeometryUnit = 0
        for i in 0..<count {
            let m = measured[i]
            let size: Size
            if m.isFlexible {
                size = subviews[i].size(in: ProposedViewSize(width: extraPerFlexible, height: height))
            } else {
                size = m.naturalSize
            }
            items[i] = ItemLayout(size: size)
            if size.height > maxHeight { maxHeight = size.height }
        }

        return StackLayout(items: items, totalWidth: finalWidth, maxHeight: maxHeight)
    }
}

// MARK: - Helper Types

private extension HStack {
    struct ItemLayout {
        let size: Size
    }
    
    struct StackLayout {
        let items: [ItemLayout]
        let totalWidth: GeometryUnit
        let maxHeight: GeometryUnit
    }
}

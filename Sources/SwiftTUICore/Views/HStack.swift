//
//  HStack.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/03/2026.
//

import Foundation
import Geometry

public struct HStack: Layout {
    private let alignment: VerticalAlignment
    private let spacing: GeometryUnit

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

        let containerHeight = proposal.height ?? 10
        let layout = calculateLayout(
            subviews: subviews,
            height: containerHeight,
            availableWidth: proposal.width
        )
        cache.layout = layout

        return Size(
            width: layout.totalWidth,
            height: layout.maxHeight
        )
    }

    public func placeSubviews(
        in bounds: Rect,
        subviews: [Subview],
        cache: inout Cache
    ) {
        guard !subviews.isEmpty else { return }

        let layout = cache.layout ?? calculateLayout(
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
        height: GeometryUnit,
        availableWidth: GeometryUnit?
    ) -> StackLayout {
        let viewInfo = subviews.map { subview -> ViewInfo in
            let naturalSize = subview.size(in: ProposedViewSize(width: nil, height: height))
            let expandedSize = subview.size(
                in: ProposedViewSize(width: Self.flexibleWidthProbe, height: height)
            )
            let isFlexible =
                expandedSize.width.isInfinite || expandedSize.width > naturalSize.width + 0.001

            return ViewInfo(
                isFlexible: isFlexible,
                naturalSize: naturalSize,
                minimumWidth: isFlexible ? 0 : naturalSize.width
            )
        }

        let totalSpacing = spacing * GeometryUnit(max(0, subviews.count - 1))
        let minimumWidth = viewInfo.reduce(0) { $0 + $1.minimumWidth } + totalSpacing
        let flexibleCount = viewInfo.filter { $0.isFlexible }.count

        let finalWidth: GeometryUnit
        if flexibleCount > 0, let availableWidth, availableWidth.isFinite {
            finalWidth = max(minimumWidth, availableWidth)
        } else {
            finalWidth = minimumWidth
        }

        let extraSpace = max(0, finalWidth - minimumWidth)
        let extraPerFlexible = flexibleCount > 0 ? extraSpace / GeometryUnit(flexibleCount) : 0

        let items = zip(subviews, viewInfo).map { subview, info -> ItemLayout in
            let width = info.minimumWidth + (info.isFlexible ? extraPerFlexible : 0)
            let size = subview.size(in: ProposedViewSize(width: width, height: height))
            return ItemLayout(size: size)
        }

        let maxHeight = items.map { $0.size.height }.max() ?? 0

        return StackLayout(
            items: items,
            totalWidth: finalWidth,
            maxHeight: maxHeight
        )
    }
}

// MARK: - Helper Types

private struct ViewInfo {
    let isFlexible: Bool
    let naturalSize: Size
    let minimumWidth: GeometryUnit
}

private struct ItemLayout {
    let size: Size
}

private struct StackLayout {
    let items: [ItemLayout]
    let totalWidth: GeometryUnit
    let maxHeight: GeometryUnit
}

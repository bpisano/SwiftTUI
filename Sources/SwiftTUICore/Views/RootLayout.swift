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
}

extension RootLayout {
    public struct Cache {
        var layout: StackLayout?
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
        let totalSize = proposal.replacingUnspecifiedDimensions()
        guard !subviews.isEmpty else { return totalSize }
        cache.layout = calculateLayout(
            subviews: subviews,
            bounds: Rect(origin: .zero, size: totalSize)
        )
        return totalSize
    }

    public func placeSubviews(
        in bounds: Rect,
        subviews: [Subview],
        cache: inout Cache
    ) {
        guard !subviews.isEmpty else { return }
        let layout = cache.layout ?? calculateLayout(subviews: subviews, bounds: bounds)
        for (index, subview) in subviews.enumerated() {
            let item = layout.items[index]
            subview.place(in: Rect(origin: item.origin, size: item.size))
        }
    }

    private func calculateLayout(subviews: [Subview], bounds: Rect) -> StackLayout {
        let proposal: ProposedViewSize = .init(
            width: bounds.width,
            height: bounds.height
        )
        let count: Int = subviews.count

        // Single pass: measure children and accumulate totalHeight inline.
        var sizes: [Size] = .init(repeating: .zero, count: count)
        var totalHeight: GeometryUnit = 0
        for i in 0..<count {
            let size = subviews[i].size(in: proposal)
            sizes[i] = size
            totalHeight += size.height
        }

        // Place children: vertically centered as a stack, each row horizontally centered.
        var items: [ItemLayout] = .init(
            repeating: ItemLayout(origin: .zero, size: .zero),
            count: count
        )
        var y = bounds.minY + (bounds.height - totalHeight) / 2
        for i in 0..<count {
            let size = sizes[i]
            let x = bounds.minX + (bounds.width - size.width) / 2
            items[i] = ItemLayout(origin: Point(x: x, y: y), size: size)
            y += size.height
        }

        return StackLayout(items: items, totalSize: bounds.size)
    }
}

extension RootLayout {
    struct ItemLayout {
        let origin: Point
        let size: Size
    }

    struct StackLayout {
        let items: [ItemLayout]
        let totalSize: Size
    }
}

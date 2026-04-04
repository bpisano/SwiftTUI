//
//  PaddingLayout.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 29/03/2026.
//

import Foundation
import Geometry

struct PaddingLayout: Layout {
    let edges: Edge.Set
    let length: GeometryUnit
}

extension PaddingLayout {
    struct Cache {
        let insets: Insets
        var childSize: Size?
    }

    func makeCache(subviews: [Subview]) -> Cache {
        Cache(insets: resolvedInsets, childSize: nil)
    }

    func updateCache(_ cache: inout Cache, subviews: [Subview]) {
        cache.childSize = nil
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview],
        cache: inout Cache
    ) -> Size {
        guard let subview = subviews.first else { return .zero }

        let childProposal = reducedProposal(from: proposal, by: cache.insets)
        let childSize = subview.size(in: childProposal)
        cache.childSize = childSize

        return Size(
            width: childSize.width + cache.insets.horizontal,
            height: childSize.height + cache.insets.vertical
        )
    }

    func placeSubviews(
        in bounds: Rect,
        subviews: [Subview],
        cache: inout Cache
    ) {
        guard let subview = subviews.first else { return }

        let childBounds = inset(bounds, by: cache.insets)
        let childSize = cache.childSize ?? subview.size(in: ProposedViewSize(childBounds.size))

        subview.place(in: Rect(origin: childBounds.origin, size: childSize))
    }
}

extension PaddingLayout {
    private var resolvedInsets: Insets {
        Insets(
            top: edges.contains(.top) ? length : 0,
            leading: edges.contains(.leading) ? length : 0,
            bottom: edges.contains(.bottom) ? length : 0,
            trailing: edges.contains(.trailing) ? length : 0
        )
    }

    private func reducedProposal(
        from proposal: ProposedViewSize,
        by insets: Insets
    ) -> ProposedViewSize {
        ProposedViewSize(
            width: proposal.width.map { max(0, $0 - insets.horizontal) },
            height: proposal.height.map { max(0, $0 - insets.vertical) }
        )
    }

    private func inset(_ rect: Rect, by insets: Insets) -> Rect {
        Rect(
            origin: Point(x: rect.minX + insets.leading, y: rect.minY + insets.top),
            size: Size(
                width: max(0, rect.width - insets.horizontal),
                height: max(0, rect.height - insets.vertical)
            )
        )
    }
}

struct Insets {
    let top: GeometryUnit
    let leading: GeometryUnit
    let bottom: GeometryUnit
    let trailing: GeometryUnit

    var horizontal: GeometryUnit { leading + trailing }
    var vertical: GeometryUnit { top + bottom }
}

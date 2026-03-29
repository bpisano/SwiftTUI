//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 29/03/2026.
//

import Foundation
import Geometry

struct PaddingLayout: Layout {
    let edges: Edge.Set
    let length: GeometryUnit

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview]
    ) -> Size {
        guard let subview = subviews.first else { return .zero }

        let insets = resolvedInsets
        let childProposal = reducedProposal(from: proposal, by: insets)
        let childSize = subview.size(in: childProposal)

        return Size(
            width: childSize.width + insets.horizontal,
            height: childSize.height + insets.vertical
        )
    }

    func placeSubviews(
        in bounds: Rect,
        subviews: [Subview]
    ) {
        guard let subview = subviews.first else { return }

        let insets = resolvedInsets
        let childBounds = inset(bounds, by: insets)
        let childSize = subview.size(in: ProposedViewSize(childBounds.size))

        subview.place(
            in: Rect(
                origin: childBounds.origin,
                size: childSize
            )
        )
    }
}

extension PaddingLayout {
    /// Convert the selected edges into the concrete inset values used by the layout.
    private var resolvedInsets: Insets {
        Insets(
            top: edges.contains(.top) ? length : 0,
            leading: edges.contains(.leading) ? length : 0,
            bottom: edges.contains(.bottom) ? length : 0,
            trailing: edges.contains(.trailing) ? length : 0
        )
    }

    /// Reduce the parent proposal before measuring the child so the reserved padding stays
    /// outside of the child’s measured content size.
    private func reducedProposal(
        from proposal: ProposedViewSize,
        by insets: Insets
    ) -> ProposedViewSize {
        ProposedViewSize(
            width: proposal.width.map { max(0, $0 - insets.horizontal) },
            height: proposal.height.map { max(0, $0 - insets.vertical) }
        )
    }

    /// Expose the remaining drawable area once the padding has been removed from the bounds.
    private func inset(
        _ rect: Rect,
        by insets: Insets
    ) -> Rect {
        Rect(
            origin: Point(
                x: rect.minX + insets.leading,
                y: rect.minY + insets.top
            ),
            size: Size(
                width: max(0, rect.width - insets.horizontal),
                height: max(0, rect.height - insets.vertical)
            )
        )
    }
}

private struct Insets {
    let top: GeometryUnit
    let leading: GeometryUnit
    let bottom: GeometryUnit
    let trailing: GeometryUnit

    var horizontal: GeometryUnit {
        leading + trailing
    }

    var vertical: GeometryUnit {
        top + bottom
    }
}

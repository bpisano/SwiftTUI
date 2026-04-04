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
}

extension FrameLayout {
    struct Cache {
        var childSize: Size?
    }

    func makeCache(subviews: [Subview]) -> Cache {
        Cache()
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

        let childSize = subview.size(in: ProposedViewSize(width: width, height: height))
        cache.childSize = childSize

        return Size(
            width: width ?? childSize.width,
            height: height ?? childSize.height
        )
    }

    func placeSubviews(
        in bounds: Rect,
        subviews: [Subview],
        cache: inout Cache
    ) {
        guard let subview = subviews.first else { return }

        let childSize = cache.childSize ?? subview.size(in: ProposedViewSize(width: width, height: height))

        let frameWidth = width ?? bounds.width
        let frameHeight = height ?? bounds.height

        let x = bounds.minX + alignmentOffset(
            childValue: childSize.width,
            containerValue: frameWidth,
            alignment: alignment.horizontal,
            hasConstraint: width != nil
        )
        let y = bounds.minY + alignmentOffset(
            childValue: childSize.height,
            containerValue: frameHeight,
            alignment: alignment.vertical,
            hasConstraint: height != nil
        )

        subview.place(in: Rect(origin: Point(x: x, y: y), size: childSize))
    }

    private func alignmentOffset(
        childValue: GeometryUnit,
        containerValue: GeometryUnit,
        alignment: HorizontalAlignment,
        hasConstraint: Bool
    ) -> GeometryUnit {
        guard hasConstraint else { return 0 }
        let childDimensions = ViewDimensions(size: Size(width: childValue, height: 0))
        let containerDimensions = ViewDimensions(size: Size(width: containerValue, height: 0))
        return alignment.key.id.defaultValue(in: containerDimensions) - alignment.key.id.defaultValue(in: childDimensions)
    }

    private func alignmentOffset(
        childValue: GeometryUnit,
        containerValue: GeometryUnit,
        alignment: VerticalAlignment,
        hasConstraint: Bool
    ) -> GeometryUnit {
        guard hasConstraint else { return 0 }
        let childDimensions = ViewDimensions(size: Size(width: 0, height: childValue))
        let containerDimensions = ViewDimensions(size: Size(width: 0, height: containerValue))
        return alignment.key.id.defaultValue(in: containerDimensions) - alignment.key.id.defaultValue(in: childDimensions)
    }
}

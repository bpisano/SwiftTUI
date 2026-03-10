//
//  VStackLayout.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

struct VStackLayout: Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> Size {
        let frames = viewFrames(proposal: proposal, subviews: subviews)
        var totalHeight: GeometryUnit = 0
        var maxWidth: GeometryUnit = 0

        for frame in frames {
            totalHeight += frame.height
            maxWidth = max(maxWidth, frame.width)
        }

        return Size(width: maxWidth, height: totalHeight)
    }

    func placeSubviews(
        in bounds: Rect,
        subviews: [LayoutProxy]
    ) {
        let frames = viewFrames(
            proposal: ProposedViewSize(bounds.size),
            subviews: subviews
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(in: frames[index])
        }
    }

    private func viewFrames(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> [Rect] {
        var frames: [Rect] = []
        var yPosition: GeometryUnit = 0

        for subview in subviews {
            let subviewSize = subview.size(in: proposal)
            let frame = Rect(
                x: 0,
                y: yPosition,
                width: subviewSize.width,
                height: subviewSize.height
            )
            frames.append(frame)
            yPosition += subviewSize.height
        }

        return frames
    }
}

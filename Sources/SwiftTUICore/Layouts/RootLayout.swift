//
//  RootLayout.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import AttributeGraph
import Foundation
import Geometry

struct RootLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: [LayoutProxy]) -> Size {
        .init(
            width: proposal.width ?? 0,
            height: proposal.height ?? 0
        )
    }

    func place(in bounds: Rect, subviews: [LayoutProxy]) {
        let frames: [Rect] = viewFrames(
            proposal: .init(bounds.size),
            subviews: subviews,
            bounds: bounds
        )
        for (index, frame) in frames.enumerated() {
            subviews[index].place(in: frame, proposal: .init(frame.size))
        }
    }

    private func viewFrames(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy],
        bounds: Rect
    ) -> [Rect] {
        // Get the ideal size of each view
        let idealSizes: [Size] = subviews.map { $0.size(in: proposal) }

        // Calculate total height of content
        let totalContentHeight: Double = idealSizes.reduce(0) { $0 + $1.height }

        // Calculate starting Y position to center content vertically
        let startY: Double = (bounds.size.height - totalContentHeight) / 2

        // Build frames for each subview
        var frames: [Rect] = Array(repeating: .zero, count: subviews.count)
        var yPosition: Double = startY

        for (index, idealSize) in idealSizes.enumerated() {
            // Center horizontally
            let xPosition: Double = (bounds.size.width - idealSize.width) / 2

            let frame = Rect(
                origin: Point(x: xPosition, y: yPosition),
                size: idealSize
            )
            frames[index] = frame

            yPosition += idealSize.height
        }

        return frames
    }
}

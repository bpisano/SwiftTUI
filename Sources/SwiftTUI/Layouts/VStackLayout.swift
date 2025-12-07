//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 05/12/2025.
//

import Foundation
import AttributeGraph
import Geometry

struct VStackLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: [LayoutProxy]) -> Size {
        let frames: [Rect] = viewFrames(proposal: proposal, subviews: subviews)
        let totalWidth: Double = frames.reduce(0) { maxWidth, frame in
            max(maxWidth, frame.size.width)
        }
        let totalHeight: Double = frames.reduce(0) { height, frame in
            height + frame.size.height
        }
        return .init(width: totalWidth, height: totalHeight)
    }

    func place(in bounds: Rect, subviews: [LayoutProxy]) {
        let frames: [Rect] = viewFrames(proposal: .init(bounds.size), subviews: subviews)
        for (index, frame) in frames.enumerated() {
            subviews[index].place(in: frame, proposal: .init(.zero))
        }
    }

    private func viewFrames(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> [Rect] {
        let allViewSize: [Size] = subviews.map { $0.size(in: proposal) }
        var sortedViewSize: [Size] = allViewSize.sorted { $0.height < $1.height }

        var remainingHeight: Double? = proposal.height
        var frames: [Rect] = Array(repeating: .zero, count: subviews.count)

        // Calculate view sizes
        while let (index, _) = sortedViewSize.enumerated().first {
            defer { sortedViewSize.removeFirst() }

            let subview: LayoutProxy = subviews[index]
            let proposedHeight: Double? = remainingHeight.map { $0 / .init(sortedViewSize.count) }
            let proposedSize: ProposedViewSize = .init(width: proposal.width, height: proposedHeight)
            let size: Size = subview.size(in: proposedSize)

            frames[index].size = size
            remainingHeight = remainingHeight.map { $0 - size.height }
        }

        // Calculate view origins
        var yPosition: Double = 0
        for (index, frame) in frames.enumerated() {
            let viewOrigin: Point = Point(x: 0, y: yPosition)
            frames[index].origin = viewOrigin
            yPosition += frame.size.height
        }

        return frames
    }
}

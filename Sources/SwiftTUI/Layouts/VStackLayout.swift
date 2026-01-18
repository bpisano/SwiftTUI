//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 05/12/2025.
//

import AttributeGraph
import Foundation
import Geometry

struct VStackLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: [LayoutProxy]) -> Size {
        print("--- VStack Layout sizeThatFits ---")
        print("VStack Layout Proposal:", proposal)
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
        print("--- VStack Layout place ---")
        print("VStack Layout Bounds:", bounds)
        let frames: [Rect] = viewFrames(proposal: .init(bounds.size), subviews: subviews)
        for (index, frame) in frames.enumerated() {
            subviews[index].place(in: frame, proposal: .init(.zero))
        }
    }

    private func viewFrames(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> [Rect] {
        // First, get the ideal size of each view (when no size is proposed)
        let idealSizes: [Size] = subviews.map { $0.size(in: .zero) }

        // Identify flexible views: views that would grow if given more space
        // A view is flexible if its height with infinite proposal is larger than its ideal height
        let flexibleViews: [Bool] = subviews.enumerated().map { index, subview in
            let infiniteSize: Size = subview.size(
                in: .init(width: proposal.width, height: .infinity))
            return infiniteSize.height > idealSizes[index].height
        }

        let flexibleCount: Int = flexibleViews.filter { $0 }.count

        // Calculate the total height used by fixed-size views
        let fixedHeight: Double = idealSizes.enumerated().reduce(0) { total, element in
            let (index, size) = element
            return flexibleViews[index] ? total : total + size.height
        }

        // Calculate remaining space for flexible views
        let remainingHeight: Double? = proposal.height.map { $0 - fixedHeight }
        let heightPerFlexibleView: Double? = remainingHeight.map {
            flexibleCount > 0 ? $0 / Double(flexibleCount) : 0
        }

        // Calculate final sizes
        var frames: [Rect] = Array(repeating: .zero, count: subviews.count)
        for index in 0..<subviews.count {
            let subview: LayoutProxy = subviews[index]
            let proposedSize: ProposedViewSize

            if flexibleViews[index] {
                // Flexible view: give it its share of remaining space
                proposedSize = .init(width: proposal.width, height: heightPerFlexibleView)
            } else {
                // Fixed view: propose unspecified height so it uses its ideal size
                proposedSize = .init(width: proposal.width, height: nil)
            }

            frames[index].size = subview.size(in: proposedSize)
        }

        // Calculate view origins
        var yPosition: Double = 0
        for index in 0..<frames.count {
            frames[index].origin = Point(x: 0, y: yPosition)
            yPosition += frames[index].size.height
        }

        return frames
    }
}

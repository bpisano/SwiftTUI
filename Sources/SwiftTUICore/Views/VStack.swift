//
//  VStack.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

public struct VStack: Layout {
    private let alignment: HorizontalAlignment
    private let spacing: GeometryUnit

    public init(
        alignment: HorizontalAlignment = .center,
        spacing: GeometryUnit = 0
    ) {
        self.alignment = alignment
        self.spacing = spacing
    }
}

extension VStack {
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview]
    ) -> Size {
        guard !subviews.isEmpty else {
            return .zero
        }

        let proposalWidth = proposal.width ?? 10

        // Get minimum sizes (same logic as computeFrames)
        let minSizes: [Size] = subviews.map { subview in
            let sizeWithNil = subview.size(
                in: ProposedViewSize(
                    width: proposalWidth,
                    height: nil
                ))
            let sizeWithInfinity = subview.size(
                in: ProposedViewSize(
                    width: proposalWidth,
                    height: .infinity
                ))

            // Flexible views have 0 minimum height
            let isFlexible =
                sizeWithInfinity.height.isInfinite
                || sizeWithInfinity.height > sizeWithNil.height + 0.001

            return isFlexible ? Size(width: sizeWithNil.width, height: 0) : sizeWithNil
        }

        // Calculate total height
        let totalSpacing = spacing * Double(max(0, subviews.count - 1))
        let minTotalHeight = minSizes.reduce(0) { $0 + $1.height } + totalSpacing

        // Use proposed height if specified, otherwise use minimum height
        let finalHeight: GeometryUnit
        if let proposedHeight = proposal.height, proposedHeight.isFinite {
            finalHeight = proposedHeight
        } else {
            finalHeight = minTotalHeight
        }

        // Use proposed width if specified, otherwise use max child width
        let finalWidth: GeometryUnit
        if let proposedWidth = proposal.width, proposedWidth.isFinite {
            finalWidth = proposedWidth
        } else {
            finalWidth = minSizes.map { $0.width }.max() ?? 0
        }

        return Size(width: finalWidth, height: finalHeight)
    }

    public func placeSubviews(
        in bounds: Rect,
        subviews: [Subview]
    ) {
        guard !subviews.isEmpty else { return }

        let frames: [Rect] = computeFrames(
            in: bounds,
            subviews: subviews
        )

        for (index, subview) in subviews.enumerated() {
            subview.place(in: frames[index])
        }
    }

    private func computeFrames(
        in bounds: Rect,
        subviews: [Subview]
    ) -> [Rect] {
        // Step 1: Identify flexible views (views that can expand)
        let flexibilityInfo: [(isFlexible: Bool, minSize: Size)] = subviews.map { subview in
            let sizeWithNil = subview.size(
                in: ProposedViewSize(
                    width: bounds.width,
                    height: nil
                ))
            let sizeWithInfinity = subview.size(
                in: ProposedViewSize(
                    width: bounds.width,
                    height: .infinity
                ))

            let isFlexible =
                sizeWithInfinity.height.isInfinite
                || sizeWithInfinity.height > sizeWithNil.height + 0.001

            // For flexible views, use 0 as minimum height
            // For non-flexible views, use their natural size
            let minSize = isFlexible ? Size(width: sizeWithNil.width, height: 0) : sizeWithNil

            return (isFlexible, minSize)
        }

        // Step 2: Calculate space distribution
        let totalSpacing = spacing * Double(max(0, subviews.count - 1))
        let minTotalHeight = flexibilityInfo.reduce(0.0) { $0 + $1.minSize.height }
        let availableHeight = bounds.height
        let remainingHeight = availableHeight - minTotalHeight - totalSpacing
        let flexibleCount = flexibilityInfo.filter { $0.isFlexible }.count

        // Distribute remaining space to flexible views
        let extraHeightPerFlexibleView =
            flexibleCount > 0 ? max(0, remainingHeight / Double(flexibleCount)) : 0

        // Step 3: Build frames
        var frames: [Rect] = []
        var yPosition: GeometryUnit = bounds.origin.y

        for (index, subview) in subviews.enumerated() {
            let info = flexibilityInfo[index]
            let isFlexible = info.isFlexible
            let minSize = info.minSize

            // Calculate height for this subview
            let height = minSize.height + (isFlexible ? extraHeightPerFlexibleView : 0)

            // Propose the calculated height to get the actual size
            let proposedSize = ProposedViewSize(
                width: bounds.width,
                height: height
            )
            let finalSize = subview.size(in: proposedSize)

            // Calculate x position based on alignment
            let xPosition: GeometryUnit = {
                let viewDimensions = ViewDimensions(size: finalSize)
                let viewAlignmentValue = alignment.key.id.defaultValue(in: viewDimensions)
                let containerDimensions = ViewDimensions(size: bounds.size)
                let containerAlignmentValue = alignment.key.id.defaultValue(in: containerDimensions)
                return bounds.origin.x + containerAlignmentValue - viewAlignmentValue
            }()

            let frame = Rect(
                x: xPosition,
                y: yPosition,
                width: finalSize.width,
                height: height
            )
            frames.append(frame)

            yPosition += height
            if index < subviews.count - 1 {
                yPosition += spacing
            }
        }

        return frames
    }
}

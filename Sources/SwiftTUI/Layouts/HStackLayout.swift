//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry
import AttributeGraph

struct HStackLayout: Layout {
    func sizeThatFits(proposal: ProposedViewSize, subviews: [LayoutProxy]) -> Size {
        let frames = self.frames(proposal: proposal, subviews: subviews)
        var totalWidth: Double = 0
        var maxHeight: Double = 0
        for frame in frames {
            totalWidth += frame.size.width
            maxHeight = max(maxHeight, frame.size.height)
        }
        return .init(width: totalWidth, height: maxHeight)
    }

    func place(in bounds: Rect, subviews: [LayoutProxy]) {
        let result = frames(proposal: .init(bounds.size), subviews: subviews)
        for (index, frame) in result.enumerated() {
            subviews[index].place(
                in: frame.offsetBy(dx: bounds.minX, dy: bounds.minY),
                proposal: .init(.zero)
            )
        }
    }

    private func frames(proposal: ProposedViewSize, subviews: [LayoutProxy]) -> [Rect] {
        var frames: [Rect] = []
        var xPosition: Double = 0
        for subview in subviews {
            let viewOrigin = Point(x: xPosition, y: 0)
            let viewSize = subview.sizeThatFits(proposal)
            frames.append(.init(origin: viewOrigin, size: viewSize))

            xPosition += viewSize.width
        }
        return frames
        //        let flexibilities = subviews.map { s in
//            let max = s.sizeThatFits(.init(width: .infinity, height: proposedSize.height)).width
//            let min = s.sizeThatFits(.init(width: 0, height: proposedSize.height)).width
//            return max - min
//        }
//        var sorted = flexibilities.enumerated().sorted {
//            $0.element < $1.element
//        }
//        var remainingWidth = proposedSize.width
//        var result: [Rect] = Array(repeating: .zero, count: subviews.count)
//        while let (index, _) = sorted.first {
//            defer { sorted.removeFirst() }
//            let proposedWidth = remainingWidth.map { $0 / .init(sorted.count) }
//            let subview = subviews[index]
//            let size = subview.sizeThatFits(.init(width: proposedWidth, height: proposedSize.height))
//            result[index].size = size
//            remainingWidth = remainingWidth.map { $0 - size.width }
//        }
//        var currentX: Double = 0
//        for (index, rect) in result.enumerated() {
//            result[index].origin.x = currentX
//            currentX += rect.width
//        }
//        return result
    }
}

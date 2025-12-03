//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation
import AttributeGraph
import Geometry

struct FrameLayout: Layout {
    private let width: Double?
    private let height: Double?
    private let alignment: Alignment

    init(
        width: Double? = nil,
        height: Double? = nil,
        alignment: Alignment = .center
    ) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: [LayoutProxy]) -> Size {
        // If both dimensions are fixed, return them directly
        if let width, let height {
            return Size(width: width, height: height)
        }

        // Get the size that fits from the first subview
        guard let subview = subviews.first else {
            return Size(
                width: width ?? proposal.width ?? 0,
                height: height ?? proposal.height ?? 0
            )
        }

        // Ask the subview for its size that fits the proposed size
        let subviewSize = subview.size(
            in: ProposedViewSize(
                width: width ?? proposal.width,
                height: height ?? proposal.height
            )
        )

        return Size(
            width: width ?? subviewSize.width,
            height: height ?? subviewSize.height
        )
    }

    func place(in bounds: Rect, subviews: [LayoutProxy]) {
        guard let subview = subviews.first else {
            return
        }

        let proposedSize = ProposedViewSize(
            width: width ?? bounds.size.width,
            height: height ?? bounds.size.height
        )

        let subviewSize: Size = subview.size(in: proposedSize)
        let subviewDimensions: ViewDimensions = .init(
            origin: bounds.origin,
            size: subviewSize
        )

        let xPosition: Double = alignment.horizontal.key.id.defaultValue(in: subviewDimensions)
        let yPosition: Double = alignment.vertical.key.id.defaultValue(in: subviewDimensions)

        let frame: Rect = .init(
            origin: Point(x: xPosition, y: yPosition),
            size: subviewSize
        )

        subview.place(in: frame, proposal: proposedSize)
    }
}

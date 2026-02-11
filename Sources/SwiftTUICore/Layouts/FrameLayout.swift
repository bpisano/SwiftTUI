//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import AttributeGraph
import Foundation
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
        if let width, let height {
            return Size(width: width, height: height)
        }

        guard let subview = subviews.first else {
            return Size(
                width: width ?? proposal.width ?? 0,
                height: height ?? proposal.height ?? 0
            )
        }

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
        subviews.forEach { subview in
            let proposal: ProposedViewSize = ProposedViewSize(
                width: width ?? bounds.size.width,
                height: height ?? bounds.size.height
            )
            let subviewSize = subview.size(in: proposal)
            let viewDimensions: ViewDimensions = .init(
                frame: .init(
                    origin: .zero,
                    size: .init(
                        width: (width ?? subviewSize.width) - subviewSize.width,
                        height: (height ?? subviewSize.height) - subviewSize.height
                    )
                )
            )
            let origin: Point = Point(
                x: alignment.horizontal.key.id.defaultValue(in: viewDimensions),
                y: alignment.vertical.key.id.defaultValue(in: viewDimensions)
            )
            let frame: Rect = Rect(
                origin: origin,
                size: subviewSize
            )
            subview.place(in: frame, proposal: .init(.zero))
        }
    }
}

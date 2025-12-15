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

        print("[STF] Proposal \(proposal.width, default: "nil")")
        let sizeThatFits = Size(
            width: proposal.width ?? width ?? subviewSize.width,
            height: proposal.height ?? height ?? subviewSize.height
        )
        print("[STF] Size that fits", sizeThatFits)

        return sizeThatFits
    }

    func place(in bounds: Rect, subviews: [LayoutProxy]) {
        subviews.forEach { subview in
            let proposal: ProposedViewSize = ProposedViewSize(
                width: width ?? bounds.size.width,
                height: height ?? bounds.size.height
            )
            let subviewSize = subview.size(in: proposal)
            let origin: Point = .zero // No alignment handling for now
            let frame: Rect = Rect(
                origin: origin,
                size: subviewSize
            )
            print("Final frame", frame)
            subview.place(in: frame, proposal: .init(.zero))
        }

//        print("[Place] Bounds", bounds)
//        print("[Place] Proposal", ProposedViewSize(
//            width: width ?? bounds.size.width,
//            height: height ?? bounds.size.height
//        ))
//
//        subviews.forEach { proxy in
//            proxy.place(
//                in: bounds,
//                proposal: ProposedViewSize(
//                    width: width ?? bounds.size.width,
//                    height: height ?? bounds.size.height
//                )
//            )
//        }
    }
}

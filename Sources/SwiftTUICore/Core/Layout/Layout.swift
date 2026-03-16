//
//  Layout.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

public protocol Layout {
    typealias Subview = LayoutProxy

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview]
    ) -> Size

    func placeSubviews(
        in bounds: Rect,
        subviews: [Subview]
    )
}

extension Layout {
    public func callAsFunction<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        LayoutView(layout: self, content: content())
    }

    func layoutComputer(for subviews: [LayoutComputer]) -> LayoutComputer {
        var geometries: [ViewGeometry] = Array(repeating: .zero, count: subviews.count)
        let proxies: [LayoutProxy] = subviews.enumerated().map { index, computer in
            LayoutProxy(layoutComputer: computer) { rect in
                geometries[index] = rect
            }
        }

        return LayoutComputer { proposal in
            sizeThatFits(proposal: proposal, subviews: proxies)
        } viewGeometries: { rect in
            placeSubviews(in: rect, subviews: proxies)
            return geometries
        }
    }
}

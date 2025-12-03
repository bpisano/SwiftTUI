//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry

protocol Layout {
    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [LayoutProxy]
    ) -> Size

    func place(
        in bounds: Rect,
        subviews: [LayoutProxy]
    )
}

extension Layout {
    func layoutComputer(for subviews: [LayoutComputer]) -> LayoutComputer {
        var geometries: [ViewGeometry] = Array(repeating: .zero, count: subviews.count)
        let proxies: [LayoutProxy] = subviews.enumerated().map { index, computer in
            LayoutProxy(layoutComputer: computer) { rect, proposal in
                let dimensions: ViewDimensions = .init(frame: rect)
                geometries[index] = .init(dimensions: dimensions)
            }
        }

        return LayoutComputer { proposal in
            sizeThatFits(proposal: proposal, subviews: proxies)
        } childGeometries: { rect in
            place(in: rect, subviews: proxies)
            return geometries
        }
    }
}

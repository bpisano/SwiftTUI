//
//  ProposedViewSize.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry

struct ProposedViewSize {
    static let zero: Self = .init(width: nil, height: nil)
    static let infinity: Self = .init(width: .infinity, height: .infinity)
    static let unspecified: Self = .init(width: nil, height: nil)

    let width: Double?
    let height: Double?

    init(width: Double?, height: Double?) {
        self.width = width
        self.height = height
    }

    init(_ size: Size) {
        self.width = size.width.isFinite ? size.width : nil
        self.height = size.height.isFinite ? size.height : nil
    }

    func replacingUnspecifiedDimensions(
        by size: Size = .init(width: 10, height: 10)
    ) -> Size {
        Size(
            width: width ?? size.width,
            height: height ?? size.height
        )
    }
}

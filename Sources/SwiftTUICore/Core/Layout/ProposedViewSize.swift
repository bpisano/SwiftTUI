//
//  ProposedViewSize.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

public struct ProposedViewSize {
    static let zero: Self = .init(width: nil, height: nil)
    static let infinity: Self = .init(width: .infinity, height: .infinity)
    static let unspecified: Self = .init(width: nil, height: nil)

    public let width: GeometryUnit?
    public let height: GeometryUnit?

    public init(
        width: GeometryUnit?,
        height: GeometryUnit?
    ) {
        self.width = width
        self.height = height
    }

    public init(_ size: Size) {
        self.width = size.width.isFinite ? size.width : nil
        self.height = size.height.isFinite ? size.height : nil
    }

    public func replacingUnspecifiedDimensions(
        by size: Size = .init(width: 10, height: 10)
    ) -> Size {
        .init(
            width: width ?? size.width,
            height: height ?? size.height
        )
    }
}

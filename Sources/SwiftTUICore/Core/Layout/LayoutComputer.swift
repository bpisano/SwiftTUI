//
//  LayoutComputer.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

struct LayoutComputer: @unchecked Sendable {
    let sizeThatFits: (_ proposedSize: ProposedViewSize) -> Size
    let viewGeometries: (_ rect: Rect) -> [ViewGeometry]
}

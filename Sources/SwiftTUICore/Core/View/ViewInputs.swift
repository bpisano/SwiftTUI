//
//  ViewInputs.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import AttributeGraph
import Foundation
import Geometry

public struct ViewInputs {
    let size: Attribute<Size>
    let position: Attribute<Point>
    let phase: Attribute<ViewPhase>

    var frame: Rect {
        .init(
            origin: position.wrappedValue,
            size: size.wrappedValue
        )
    }

    public init(
        position: Attribute<Point>,
        size: Attribute<Size>,
        phase: Attribute<ViewPhase>
    ) {
        self.size = size
        self.position = position
        self.phase = phase
    }
}

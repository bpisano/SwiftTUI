//
//  ViewInputs.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry
import AttributeGraph

public struct ViewInputs: InputStorage {
    let position: Attribute<Point>
    let size: Attribute<Size>
    let phase: Attribute<ViewPhase>

    var storage: ViewInputsStorage

    public init(
        position: Attribute<Point>,
        size: Attribute<Size>,
        phase: Attribute<ViewPhase>,
        storage: ViewInputsStorage
    ) {
        self.position = position
        self.size = size
        self.phase = phase
        self.storage = storage
    }
}

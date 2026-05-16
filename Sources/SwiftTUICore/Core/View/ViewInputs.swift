//
//  ViewInputs.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry
import AttributeGraph

public struct ViewInputs: InputStorage, Sendable {
    let position: Attribute<Point>
    let size: Attribute<Size>
    let phase: Attribute<ViewPhase>

    var environment: Attribute<EnvironmentValues>
    var storage: ViewInputsStorage

    @MainActor
    var frame: Rect {
        .init(
            origin: position.wrappedValue,
            size: size.wrappedValue
        )
    }

    public init(
        position: Attribute<Point>,
        size: Attribute<Size>,
        phase: Attribute<ViewPhase>,
        environment: Attribute<EnvironmentValues>,
        storage: ViewInputsStorage
    ) {
        self.position = position
        self.size = size
        self.phase = phase
        self.environment = environment
        self.storage = storage
    }
}

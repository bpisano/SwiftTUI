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

    private(set) var storage: ViewInputsStorage

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
    ) {
        self.init(
            position: position,
            size: size,
            phase: phase,
            storage: .init()
        )
    }

    init(
        position: Attribute<Point>,
        size: Attribute<Size>,
        phase: Attribute<ViewPhase>,
        storage: ViewInputsStorage
    ) {
        self.size = size
        self.position = position
        self.phase = phase
        self.storage = storage
    }

    mutating func append<Key: ViewInputKey>(_ value: Key.Value, to keyType: Key.Type) {
        storage.append(value, to: keyType)
    }

    mutating func popLast<Key: ViewInputKey>(_ keyType: Key.Type) -> Key.Value? {
        storage.popLast(keyType)
    }
}

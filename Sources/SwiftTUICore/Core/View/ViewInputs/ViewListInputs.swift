//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/11/2025.
//

import AttributeGraph
import Foundation
import Geometry

public struct ViewListInputs {
    private(set) var storage: ViewInputsStorage

    init(storage: ViewInputsStorage = .init()) {
        self.storage = storage
    }

    init(from inputs: ViewInputs) {
        self.init(storage: inputs.storage)
    }

    mutating func append<Key: ViewInputKey>(_ value: Key.Value, to keyType: Key.Type) {
        storage.append(value, to: keyType)
    }

    mutating func popLast<Key: ViewInputKey>(_ keyType: Key.Type) -> Key.Value? {
        storage.popLast(keyType)
    }
}

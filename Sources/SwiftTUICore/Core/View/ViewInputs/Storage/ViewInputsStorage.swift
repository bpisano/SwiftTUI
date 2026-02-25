//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation

struct ViewInputsStorage {
    private var storage: [ObjectIdentifier: Any] = [:]

    subscript<Key: ViewInputKey>(keyType: Key.Type) -> Key.Value? {
        storage[ObjectIdentifier(keyType)] as? Key.Value
    }

    mutating func append<Key: ViewInputKey>(_ value: Key.Value, to keyType: Key.Type) {
        storage[ObjectIdentifier(keyType)] = value
    }

    mutating func popLast<Key: ViewInputKey>(_ keyType: Key.Type) -> Key.Value? {
        let id: ObjectIdentifier = .init(keyType)
        let value: Key.Value? = storage[id] as? Key.Value
        storage.removeValue(forKey: id)
        return value
    }
}

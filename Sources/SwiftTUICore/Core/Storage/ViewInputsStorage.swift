//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation

@_documentation(visibility: internal)
@MainActor
public final class ViewInputsStorage {
    private var storage: [ObjectIdentifier: Any]

    public init() {
        self.storage = [:]
    }

    subscript<Key: ViewInputsStorageKey>(keyType: Key.Type) -> Key.Value? {
        storage[ObjectIdentifier(keyType)] as? Key.Value
    }

    func append<Key: ViewInputsStorageKey>(_ value: Key.Value, to keyType: Key.Type) {
        storage[ObjectIdentifier(keyType)] = value
    }

    func popLast<Key: ViewInputsStorageKey>(_ keyType: Key.Type) -> Key.Value? {
        let id: ObjectIdentifier = .init(keyType)
        let value: Key.Value? = storage[id] as? Key.Value
        storage.removeValue(forKey: id)
        return value
    }
}

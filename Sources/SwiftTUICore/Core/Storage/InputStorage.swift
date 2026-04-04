//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation

protocol InputStorage {
    var storage: ViewInputsStorage { get set }
}

extension InputStorage {
    @MainActor
    func append<Key: ViewInputsStorageKey>(_ value: Key.Value, to keyType: Key.Type) {
        storage.append(value, to: keyType)
    }

    @MainActor
    func popLast<Key: ViewInputsStorageKey>(_ keyType: Key.Type) -> Key.Value? {
        storage.popLast(keyType)
    }
}

//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation

public struct EnvironmentValues {
    private var storage: [ObjectIdentifier: Any] = [:]

    public init(storage: [ObjectIdentifier: Any] = [:]) {
        self.storage = storage
    }

    public subscript<Key: EnvironmentKey>(_ key: Key.Type) -> Key.Value {
        get { storage[ObjectIdentifier(key)] as? Key.Value ?? key.defaultValue }
        set { storage[ObjectIdentifier(key)] = newValue }
    }
}

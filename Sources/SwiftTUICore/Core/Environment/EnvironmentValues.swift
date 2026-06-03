//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation

/// A collection of values propagated down the view hierarchy.
///
/// Values are keyed by their `EnvironmentKey` type and fall back to the key's default
/// value when not set. Read a value with the ``Environment`` property wrapper, and set
/// values on a subtree using the corresponding view modifiers.
public struct EnvironmentValues {
    private var storage: [ObjectIdentifier: Any] = [:]

    /// Creates an environment with optional initial storage.
    ///
    /// - Parameter storage: Backing storage keyed by environment key type identifier. Defaults to empty.
    public init(storage: [ObjectIdentifier: Any] = [:]) {
        self.storage = storage
    }

    /// Accesses the value for the given environment key type.
    ///
    /// Returns the key's default value when no value has been set.
    public subscript<Key: EnvironmentKey>(_ key: Key.Type) -> Key.Value {
        get { storage[ObjectIdentifier(key)] as? Key.Value ?? key.defaultValue }
        set { storage[ObjectIdentifier(key)] = newValue }
    }
}

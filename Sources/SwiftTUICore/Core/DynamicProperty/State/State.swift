//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation

@propertyWrapper
public final class State<Value>: DynamicProperty {
    private nonisolated var value: Value
    private var storage: StateStorage<Value>?

    public var wrappedValue: Value {
        get {
            if let storage {
                return storage.value
            }
            print("Warning: Accessing a @State variable outside of a View context. Returning initial value.")
            return value
        }
        set {
            guard let storage else {
                print("Warning: Attempting to set a @State variable outside of a View context. The value will not persist.")
                return
            }
            storage.setValue(newValue)
        }
    }

    public nonisolated init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public func update() {
        guard storage == nil else { return }
        storage = StateStorage(initialValue: value)
    }
}

extension State: Sendable where Value: Sendable {}

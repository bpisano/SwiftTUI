//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

@propertyWrapper
public struct Binding<Value> {
    private let get: () -> Value
    private let set: (Value) -> Void

    public var wrappedValue: Value {
        get {
            get()
        }
        nonmutating set {
            set(newValue)
        }
    }

    public init(
        get: @escaping () -> Value,
        set: @escaping (Value) -> Void
    ) {
        self.get = get
        self.set = set
    }
}

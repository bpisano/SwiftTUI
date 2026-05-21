//
//  Binding.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 2026-05-21.
//

import Foundation

@MainActor
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value> {
    private let getter: @MainActor () -> Value
    private let setter: @MainActor (Value) -> Void

    public var wrappedValue: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }

    public var projectedValue: Binding<Value> { self }

    public init(
        get: @escaping @MainActor () -> Value,
        set: @escaping @MainActor (Value) -> Void
    ) {
        self.getter = get
        self.setter = set
    }

    public static func constant(_ value: Value) -> Binding<Value> {
        Binding(get: { value }, set: { _ in })
    }

    public subscript<Subject>(
        dynamicMember keyPath: WritableKeyPath<Value, Subject>
    ) -> Binding<Subject> {
        Binding<Subject>(
            get: { self.wrappedValue[keyPath: keyPath] },
            set: { newValue in
                var current = self.wrappedValue
                current[keyPath: keyPath] = newValue
                self.wrappedValue = current
            }
        )
    }
}

extension Binding: Sendable where Value: Sendable {}

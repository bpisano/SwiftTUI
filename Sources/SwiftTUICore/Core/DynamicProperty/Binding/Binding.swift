//
//  Binding.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

/// A two-way reference to a value owned elsewhere.
///
/// A binding connects a property to a source of truth such as ``State``, letting a
/// child view read and write a value it does not own. Get a binding from a ``State``
/// property using the `$` prefix.
///
/// Use dynamic member lookup to derive a binding to a property of the value.
///
/// ```swift
/// struct Parent: View {
///     @State private var name: String = ""
///
///     var body: some View {
///         TextField("Name", text: $name)
///     }
/// }
/// ```
@MainActor
@propertyWrapper
@dynamicMemberLookup
public struct Binding<Value> {
    private let getter: @MainActor () -> Value
    private let setter: @MainActor (Value) -> Void

    /// The value referenced by the binding.
    ///
    /// Reading calls the getter; writing calls the setter on the source of truth.
    public var wrappedValue: Value {
        get { getter() }
        nonmutating set { setter(newValue) }
    }

    /// The binding itself, accessed with the `$` prefix.
    public var projectedValue: Binding<Value> { self }

    /// Creates a binding from a getter and setter.
    ///
    /// - Parameters:
    ///   - get: A closure that returns the current value.
    ///   - set: A closure that stores a new value.
    public init(
        get: @escaping @MainActor () -> Value,
        set: @escaping @MainActor (Value) -> Void
    ) {
        self.getter = get
        self.setter = set
    }

    /// Creates a binding to a fixed value.
    ///
    /// The value never changes and writes are ignored. Useful for previews and tests.
    ///
    /// - Parameter value: The constant value to return.
    public static func constant(_ value: Value) -> Binding<Value> {
        Binding(get: { value }, set: { _ in })
    }

    /// Returns a binding to a property of the value, using the property's key path.
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

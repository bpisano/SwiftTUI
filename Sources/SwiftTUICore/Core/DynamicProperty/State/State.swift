//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation

/// A property wrapper that stores mutable state owned by a ``View``.
///
/// Declare state as private and give it an initial value. The view's storage is
/// created the first time the view is rendered, and persists across re-renders.
/// Mutating ``wrappedValue`` schedules the view to re-render.
///
/// Read and write the value through the wrapper, and use the `$` prefix to get a
/// ``Binding`` for passing write access to child views.
///
/// ```swift
/// struct Counter: View {
///     @State private var count: Int = 0
///
///     var body: some View {
///         Button("Count: \(count)") {
///             count += 1
///         }
///     }
/// }
/// ```
@MainActor
@propertyWrapper
public final class State<Value>: @MainActor DynamicProperty {
    private nonisolated var value: Value
    private var storage: StateStorage<Value>?

    /// The current value of the state.
    ///
    /// Accessing this outside of a ``View`` returns the initial value and does not persist changes.
    public var wrappedValue: Value {
        get {
            if let storage {
                return storage.value
            }
            assertionFailure("Accessing a @State variable outside of a View context. Returning initial value.")
            return value
        }
        set {
            guard let storage else {
                assertionFailure("Attempting to set a @State variable outside of a View context. The value will not persist.")
                return
            }
            storage.setValue(newValue)
        }
    }

    /// A ``Binding`` to the state value, accessed with the `$` prefix.
    ///
    /// Pass the binding to child views that need to read and write the value.
    public var projectedValue: Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { self.wrappedValue = $0 }
        )
    }

    /// Creates state with an initial value.
    ///
    /// - Parameter wrappedValue: The initial value, used until the view's storage is created.
    public nonisolated init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    public func update() {
        guard storage == nil else { return }
        storage = StateStorage(initialValue: value)
    }
}

extension State: Sendable where Value: Sendable {}

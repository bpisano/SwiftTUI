//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation
import AttributeGraph

/// A property wrapper that reads a value from the view's ``EnvironmentValues``.
///
/// Specify a key path to the value when declaring the property. The wrapper reads
/// the value from the environment of the enclosing ``View`` and updates when that
/// value changes.
///
/// ```swift
/// struct Label: View {
///     @Environment(\.foregroundColor) private var color
///
///     var body: some View {
///         Text("Hello").foregroundColor(color)
///     }
/// }
/// ```
@MainActor
@propertyWrapper
public final class Environment<Value>: @MainActor EnvironmentProperty {
    private let keyPath: KeyPath<EnvironmentValues, Value>

    var environment: Attribute<EnvironmentValues>?

    /// The current value read from the environment.
    ///
    /// Accessing this before the property is installed on a ``View`` returns the default value and does not update.
    public var wrappedValue: Value {
        guard let environment = environment else {
            assertionFailure("Accessing @Environment's value outside of being installed on a View. This will always read the default value and will not update.")
            return EnvironmentValues()[keyPath: keyPath]
        }
        return environment.wrappedValue[keyPath: keyPath]
    }

    /// Creates an environment property for the given key path.
    ///
    /// - Parameter keyPath: A key path into ``EnvironmentValues`` identifying the value to read.
    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }

    func update(environment: Attribute<EnvironmentValues>) {
        self.environment = environment
    }
}

extension Environment: Sendable where Value: Sendable {}

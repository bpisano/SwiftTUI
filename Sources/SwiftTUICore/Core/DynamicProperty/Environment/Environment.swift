//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation
import AttributeGraph

@MainActor
@propertyWrapper
public final class Environment<Value>: @MainActor EnvironmentProperty {
    private let keyPath: KeyPath<EnvironmentValues, Value>

    var environment: Attribute<EnvironmentValues>?

    public var wrappedValue: Value {
        guard let environment = environment else {
            assertionFailure("Accessing @Environment's value outside of being installed on a View. This will always read the default value and will not update.")
            return EnvironmentValues()[keyPath: keyPath]
        }
        return environment.wrappedValue[keyPath: keyPath]
    }

    public init(_ keyPath: KeyPath<EnvironmentValues, Value>) {
        self.keyPath = keyPath
    }

    func update(environment: Attribute<EnvironmentValues>) {
        self.environment = environment
    }
}

extension Environment: Sendable where Value: Sendable {}

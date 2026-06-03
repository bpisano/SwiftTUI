//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation
import AttributeGraph

struct EnvironmentKeyWritingViewModifier<Value>: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    let keyPath: WritableKeyPath<EnvironmentValues, Value>
    let value: Value

    init(
        keyPath: WritableKeyPath<EnvironmentValues, Value>,
        value: Value
    ) {
        self.keyPath = keyPath
        self.value = value
    }
}

extension EnvironmentKeyWritingViewModifier {
    static func makeView(
        _ modifier: Attribute<EnvironmentKeyWritingViewModifier<Value>>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        let childEnvironment: ChildEnvironment<Value> = .init(
            parent: inputs.environment,
            viewModifier: modifier
        )
        let childEnvironmentAttribute: Attribute<EnvironmentValues> = .init(
            "Derived Environment Values",
            rule: childEnvironment
        )

        var modifiedInputs: ViewInputs = inputs
        modifiedInputs.environment = childEnvironmentAttribute

        return makeViewOutputs(modifiedInputs)
    }
}

extension View {
    /// Sets an environment value for this view and its subviews.
    ///
    /// Use this to write a value into the ``EnvironmentValues`` read by
    /// descendant views through the `@Environment` property wrapper.
    ///
    /// - Parameters:
    ///   - keyPath: A key path to the environment value to set.
    ///   - value: The value to set for the given key path.
    public func environment<Value>(
        _ keyPath: WritableKeyPath<EnvironmentValues, Value>,
        _ value: Value
    ) -> some View {
        modifier(
            EnvironmentKeyWritingViewModifier(
                keyPath: keyPath,
                value: value
            )
        )
    }
}

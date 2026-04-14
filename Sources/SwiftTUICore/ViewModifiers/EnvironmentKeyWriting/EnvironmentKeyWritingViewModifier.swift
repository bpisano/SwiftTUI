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

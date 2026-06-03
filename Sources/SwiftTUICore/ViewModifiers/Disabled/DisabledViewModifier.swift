//
//  DisabledViewModifier.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph

struct DisabledViewModifier: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    let isDisabled: Bool

    init(isDisabled: Bool) {
        self.isDisabled = isDisabled
    }
}

extension DisabledViewModifier {
    static func makeView(
        _ modifier: Attribute<DisabledViewModifier>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        let childEnvironment = Attribute("Disabled Environment") {
            var env = inputs.environment.wrappedValue
            // Sticky AND combine: once disabled, descendants stay disabled.
            env.isEnabled = env.isEnabled && !modifier.wrappedValue.isDisabled
            return env
        }

        var modifiedInputs: ViewInputs = inputs
        modifiedInputs.environment = childEnvironment

        return makeViewOutputs(modifiedInputs)
    }
}

extension View {
    /// Disables user interaction for this view and its subviews.
    ///
    /// The effect is sticky: once a view is disabled, descendants stay disabled
    /// even if a nested call passes `false`. Disabled views read
    /// ``EnvironmentValues/isEnabled`` as `false`.
    ///
    /// - Parameter isDisabled: A Boolean value that determines whether the view
    ///   is disabled. Defaults to `true`.
    public func disabled(_ isDisabled: Bool = true) -> some View {
        modifier(DisabledViewModifier(isDisabled: isDisabled))
    }
}

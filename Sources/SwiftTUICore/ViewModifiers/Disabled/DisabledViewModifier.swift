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
    public func disabled(_ isDisabled: Bool = true) -> some View {
        modifier(DisabledViewModifier(isDisabled: isDisabled))
    }
}

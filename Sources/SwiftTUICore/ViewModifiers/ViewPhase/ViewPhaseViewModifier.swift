//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation
import AttributeGraph

struct ViewPhaseViewModifier: ViewModifier, UnaryViewModifier, PrimitiveViewModifier {
    let onAppear: (() -> Void)?
    let onDisappear: (() -> Void)?
}

extension ViewPhaseViewModifier {
    static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        body: @escaping (ViewInputs) -> ViewOutputs
    ) -> ViewOutputs {
        let effect = ViewPhaseEffect(modifier: modifier, phase: inputs.phase)
        let effectAttribute = Attribute(rule: effect)
        effectAttribute.flags = [.transactional]

        let modifier: Self = modifier.wrappedValue
        if modifier.onAppear != nil {
            effectAttribute.label = "onAppear closure"
        } else if modifier.onDisappear != nil {
            effectAttribute.label = "onDisappear closure"
        } else {
            effectAttribute.label = "No appearance closures"
        }

        _ = effectAttribute.wrappedValue

        return body(inputs)
    }
}

extension View {
    public func onAppear(_ action: @escaping () -> Void) -> some View {
        modifier(
            ViewPhaseViewModifier(
                onAppear: action,
                onDisappear: nil
            )
        )
    }

    public func onDisappear(_ action: @escaping () -> Void) -> some View {
        modifier(
            ViewPhaseViewModifier(
                onAppear: nil,
                onDisappear: action
            )
        )
    }
}

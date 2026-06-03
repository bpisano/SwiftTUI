//
//  InputEventModifier.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 05/02/2026.
//

import Foundation
import Terminal
import AttributeGraph

struct InputEventViewModifier<I: Input>: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    let input: I
    let onEvent: MainActorEventHandler<I.Event>

    init(
        input: I,
        onEvent: @escaping @MainActor (I.Event) -> Void
    ) {
        self.input = input
        self.onEvent = .init(onEvent)
    }

    static func makeView(
        _ modifier: Attribute<InputEventViewModifier<I>>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        let effect = InputEventEffect(modifier: modifier, phase: inputs.phase)
        let effectAttribute = Attribute(rule: effect)
        effectAttribute.flags = [.transactional]
        effectAttribute.label = "\(Self.self) effect"

        _ = effectAttribute.wrappedValue

        return makeViewOutputs(inputs)
    }
}

extension View {
    /// Runs an action when the given input source emits an event.
    ///
    /// The subscription is active only while the view is on screen. The action
    /// runs on the main actor.
    ///
    /// - Parameters:
    ///   - input: The input source to observe.
    ///   - action: A closure called with each emitted event.
    public func onEvent<I: Input>(
        of input: I,
        _ action: @escaping @MainActor (_ event: I.Event) -> Void
    ) -> some View {
        modifier(InputEventViewModifier(input: input, onEvent: action))
    }
}

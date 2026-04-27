//
//  KeyboardEventViewModifier.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 26/04/2026.
//

import Foundation
import Terminal
import AttributeGraph

struct KeyboardEventViewModifier: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    enum Trigger {
        case pressed
        case down
        case up
    }

    private let keyboard: Keyboard
    private let trigger: Trigger
    private let key: Keyboard.Key?
    private let modifiers: Keyboard.Modifiers?
    private let action: MainActorEventHandler<Keyboard.Event>

    init(
        keyboard: Keyboard = .current,
        trigger: Trigger,
        key: Keyboard.Key?,
        modifiers: Keyboard.Modifiers?,
        action: @escaping @MainActor (Keyboard.Event) -> Void
    ) {
        self.keyboard = keyboard
        self.trigger = trigger
        self.key = key
        self.modifiers = modifiers
        self.action = .init(action)
    }

    static func makeView(
        _ modifier: Attribute<KeyboardEventViewModifier>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        let inputModifier = modifier.map { modifier in
            InputEventViewModifier(input: modifier.keyboard) { event in
                guard modifier.matches(event) else { return }
                modifier.action(event)
            }
        }

        inputModifier.label = "\(Self.self) input event"

        return InputEventViewModifier.makeView(
            inputModifier,
            inputs: inputs,
            makeViewOutputs: makeViewOutputs
        )
    }

    private func matches(_ event: Keyboard.Event) -> Bool {
        guard matchesTrigger(event) else { return false }

        if let key, event.key != key {
            return false
        }

        if let modifiers, event.modifiers != modifiers {
            return false
        }

        return true
    }

    private func matchesTrigger(_ event: Keyboard.Event) -> Bool {
        switch trigger {
        case .pressed:
            return event.isPressed
        case .down:
            return event.phase == .down
        case .up:
            return event.phase == .up
        }
    }
}

extension View {
    public func onKeyPressed(
        _ key: Keyboard.Key? = nil,
        modifiers: Keyboard.Modifiers? = nil,
        _ action: @escaping @MainActor (_ event: Keyboard.Event) -> Void
    ) -> some View {
        modifier(
            KeyboardEventViewModifier(
                trigger: .pressed,
                key: key,
                modifiers: modifiers,
                action: action
            )
        )
    }

    public func onKeyDown(
        _ key: Keyboard.Key? = nil,
        modifiers: Keyboard.Modifiers? = nil,
        _ action: @escaping @MainActor (_ event: Keyboard.Event) -> Void
    ) -> some View {
        modifier(
            KeyboardEventViewModifier(
                trigger: .down,
                key: key,
                modifiers: modifiers,
                action: action
            )
        )
    }

    public func onKeyUp(
        _ key: Keyboard.Key? = nil,
        modifiers: Keyboard.Modifiers? = nil,
        _ action: @escaping @MainActor (_ event: Keyboard.Event) -> Void
    ) -> some View {
        modifier(
            KeyboardEventViewModifier(
                trigger: .up,
                key: key,
                modifiers: modifiers,
                action: action
            )
        )
    }
}

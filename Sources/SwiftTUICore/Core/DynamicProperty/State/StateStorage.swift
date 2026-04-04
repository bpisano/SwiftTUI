//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation
import AttributeGraph

@MainActor
final class StateStorage<Value> {
    var value: Value {
        _value.wrappedValue
    }

    private var _value: Attribute<Value>
    private var onUpdate: (() -> Void)?

    init(initialValue: Value) {
        self._value = Attribute(wrappedValue: initialValue)
        _value.label = "@State"
    }

    func setValue(_ newValue: Value) {
        if
            let equatable = _value as? any Equatable,
            let newEquatable = newValue as? any Equatable,
            equatable.isEqual(to: newEquatable)
        {
            return
        }

        _value.wrappedValue = newValue
        onUpdate?()
    }

    func onUpdate(_ action: @escaping () -> Void) {
        self.onUpdate = action
    }
}

private extension Equatable {
    func isEqual(to other: any Equatable) -> Bool {
        guard let otherValue = other as? Self else { return false }
        return self == otherValue
    }
}

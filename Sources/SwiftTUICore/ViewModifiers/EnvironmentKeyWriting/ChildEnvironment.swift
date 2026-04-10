//
//  ChildEnvironment.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation
import AttributeGraph

struct ChildEnvironment<Value>: Rule {
    private let parent: Attribute<EnvironmentValues>
    private let keyPath: WritableKeyPath<EnvironmentValues, Value>
    private let value: Value

    init(
        parent: Attribute<EnvironmentValues>,
        keyPath: WritableKeyPath<EnvironmentValues, Value>,
        value: Value
    ) {
        self.parent = parent
        self.keyPath = keyPath
        self.value = value
    }

    func evaluate() -> EnvironmentValues {
        var modifiedEnvironment: EnvironmentValues = parent.wrappedValue
        modifiedEnvironment[keyPath: keyPath] = value
        return modifiedEnvironment
    }
}

extension ChildEnvironment: Equatable where Value: Equatable {
    static func == (lhs: ChildEnvironment<Value>, rhs: ChildEnvironment<Value>) -> Bool {
        lhs.value == rhs.value
    }
}

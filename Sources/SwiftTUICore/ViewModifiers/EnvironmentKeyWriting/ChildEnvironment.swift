//
//  ChildEnvironment.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation
import AttributeGraph

@MainActor
struct ChildEnvironment<Value>: @MainActor Rule {
    private let parent: Attribute<EnvironmentValues>
    private let viewModifier: Attribute<EnvironmentKeyWritingViewModifier<Value>>

    init(
        parent: Attribute<EnvironmentValues>,
        viewModifier: Attribute<EnvironmentKeyWritingViewModifier<Value>>
    ) {
        self.parent = parent
        self.viewModifier = viewModifier
    }

    func evaluate() -> EnvironmentValues {
        let modifier: EnvironmentKeyWritingViewModifier<Value> = viewModifier.wrappedValue
        var modifiedEnvironment: EnvironmentValues = parent.wrappedValue
        modifiedEnvironment[keyPath: modifier.keyPath] = modifier.value
        return modifiedEnvironment
    }
}

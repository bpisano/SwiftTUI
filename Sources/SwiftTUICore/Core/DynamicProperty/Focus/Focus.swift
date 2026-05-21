//
//  Focus.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph

@MainActor
@propertyWrapper
public final class Focus: @MainActor EnvironmentProperty {
    var environment: Attribute<EnvironmentValues>?

    public var wrappedValue: Focus { self }

    public var projectedValue: Focus { self }

    public init() {}

    func update(environment: Attribute<EnvironmentValues>) {
        self.environment = environment
    }

    @discardableResult
    public func callAsFunction(_ direction: Direction) -> Bool {
        guard let manager = environment?.wrappedValue.focusManager else { return false }
        switch direction {
        case .next:
            return manager.move(.next)
        case .previous:
            return manager.move(.previous)
        case .up:
            return manager.move(.up)
        case .down:
            return manager.move(.down)
        case .left:
            return manager.move(.left)
        case .right:
            return manager.move(.right)
        case .clear:
            manager.clearFocus()
            return true
        }
    }
}

extension Focus {
    public enum Direction: Sendable {
        case next
        case previous
        case up
        case down
        case left
        case right
        case clear
    }
}

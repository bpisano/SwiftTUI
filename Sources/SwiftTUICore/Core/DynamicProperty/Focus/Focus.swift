//
//  Focus.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import AttributeGraph

/// A property wrapper that moves keyboard focus imperatively.
///
/// Declare a `@Focus` property in a view and call it to move focus in a
/// direction, mirroring the keys the runtime handles automatically:
///
/// ```swift
/// struct Toolbar: View {
///     @Focus private var focus
///
///     var body: some View {
///         Button("Next") {
///             focus(.next)
///         }
///     }
/// }
/// ```
///
/// Use this to drive focus from your own logic; for binding focus to state,
/// use ``View/focused(_:)`` or ``View/focused(_:equals:)`` instead.
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

    /// Moves focus in the given direction.
    ///
    /// - Parameter direction: Where to move focus, or ``Direction/clear`` to
    ///   drop focus entirely.
    /// - Returns: `true` if focus moved, `false` if there was no eligible view.
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
    /// A direction to move keyboard focus.
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

//
//  ViewModifier.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import AttributeGraph
import Foundation

/// A reusable transformation applied to a ``View``.
///
/// Conform to `ViewModifier` and implement ``body(content:)`` to wrap or change the
/// view passed in as `content`, returning a new view. Apply a modifier with the
/// `modifier(_:)` method on a view.
@MainActor
public protocol ViewModifier {
    /// The type of view produced by ``body(content:)``.
    associatedtype Body: View

    typealias MakeViewOutputs = (ViewInputs) -> ViewOutputs
    typealias MakeViewListOutputs = (ViewListInputs) -> ViewListOutputs

    /// The view passed into ``body(content:)``, representing the view being modified.
    typealias Content = ViewModifierContent<Self>

    static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs

    static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        makeViewListOutputs: @escaping MakeViewListOutputs
    ) -> ViewListOutputs

    /// Returns the modified view.
    ///
    /// - Parameter content: A proxy for the view being modified. Include it in the
    ///   returned view to keep the original content.
    func body(content: Content) -> Body
}

extension ViewModifier {
    public static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        inputs.append(.view(makeViewOutputs), to: MakeViewOutputsInputStorageKey.self)

        let cache: DynamicPropertyCache = .init()
        let environment: Attribute<EnvironmentValues> = inputs.environment
        let modifiedBody = Attribute("\(Self.self) body") {
            modifier.updateDynamicProperties(cache: cache, environment: environment)
            let modifierContent: ViewModifierContent<Self> = .init()
            return modifier.wrappedValue.body(content: modifierContent)
        }

        return Body.makeView(modifiedBody, inputs: inputs)
    }

    public static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        makeViewListOutputs: @escaping MakeViewListOutputs
    ) -> ViewListOutputs {
        inputs.append(.viewList(makeViewListOutputs), to: MakeViewOutputsInputStorageKey.self)

        let cache: DynamicPropertyCache = .init()
        let environment: Attribute<EnvironmentValues> = inputs.environment
        let modifiedBody = Attribute("\(Self.self) body") {
            modifier.updateDynamicProperties(cache: cache, environment: environment)
            let modifierContent: ViewModifierContent<Self> = .init()
            return modifier.wrappedValue.body(content: modifierContent)
        }

        return Body.makeViewList(modifiedBody, inputs: inputs)
    }
}

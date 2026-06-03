//
//  View.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

/// A piece of the terminal user interface.
///
/// Conform to `View` and describe the interface by composing other views in the
/// `body` property. Views are values; the engine renders them and re-renders when
/// the ``State`` they depend on changes.
///
/// ```swift
/// struct Greeting: View {
///     let name: String
///
///     var body: some View {
///         Text("Hello, \(name)")
///     }
/// }
/// ```
@MainActor
public protocol View {
    /// The type of view produced by `body`.
    associatedtype Body: View

    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs

    /// The content and layout of this view.
    ///
    /// Compose other views here. The engine reads this property to render the view.
    @ViewBuilder
    var body: Self.Body { get }
}

extension View {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let body = view.map(\.body)
        body.label = "\(Body.self)"
        view.updateDynamicProperties(environment: inputs.environment)
        return Body.makeView(body, inputs: inputs)
    }

    public static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let body = view.map(\.body)
        body.label = "\(Body.self)"
        view.updateDynamicProperties(environment: inputs.environment)
        return Body.makeViewList(body, inputs: inputs)
    }
}

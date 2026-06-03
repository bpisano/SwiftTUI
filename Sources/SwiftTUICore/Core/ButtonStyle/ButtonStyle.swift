//
//  ButtonStyle.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

/// Defines the appearance of a button.
///
/// Conform to `ButtonStyle` and implement ``makeBody(configuration:)`` to build the
/// button's view from its label and current state. Apply a style with the
/// `buttonStyle(_:)` modifier.
@MainActor
public protocol ButtonStyle {
    /// The type of view produced by ``makeBody(configuration:)``.
    associatedtype Body: View

    /// The properties of the button, including its label and interaction state.
    typealias Configuration = ButtonStyleConfiguration

    /// Returns the view that represents the styled button.
    ///
    /// - Parameter configuration: The button's label and current state.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body
}

//
//  ButtonStyleEnvironment.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

struct ButtonStyleEnvironmentKey: EnvironmentKey {
    static let defaultValue: AnyButtonStyle = {
        MainActor.assumeIsolated {
            AnyButtonStyle(DefaultButtonStyle())
        }
    }()
}

extension EnvironmentValues {
    public var buttonStyle: AnyButtonStyle {
        get { self[ButtonStyleEnvironmentKey.self] }
        set { self[ButtonStyleEnvironmentKey.self] = newValue }
    }
}

extension View {
    /// Sets the style used to draw buttons in this view's subtree.
    ///
    /// - Parameter style: A ``ButtonStyle`` that builds each button's view from
    ///   its label and state.
    ///
    /// ```swift
    /// VStack {
    ///     Button("Save") { save() }
    ///     Button("Cancel") { cancel() }
    /// }
    /// .buttonStyle(BracketButtonStyle())
    /// ```
    public func buttonStyle<S: ButtonStyle>(_ style: S) -> some View {
        environment(\.buttonStyle, AnyButtonStyle(style))
    }
}

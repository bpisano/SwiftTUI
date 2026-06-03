//
//  Button.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Terminal

/// A control that performs an action when the user presses Return.
///
/// A button becomes focusable when enabled. While focused, pressing Return runs
/// its action and briefly shows a pressed state. Use ``View/disabled(_:)`` to
/// prevent interaction.
///
/// ```swift
/// Button {
///     print("tapped")
/// } label: {
///     Text("Continue")
/// }
/// ```
public struct Button<Label: View>: View {
    private let action: @MainActor () -> Void
    private let label: Label

    @State private var isFocused: Bool = false
    @State private var isPressed: Bool = false

    @Environment(\.isEnabled) private var isEnabled

    /// Creates a button with an action and a custom label view.
    ///
    /// - Parameters:
    ///   - action: The closure to run when the button is pressed.
    ///   - label: A view builder that produces the button's label.
    public init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        let styled = StyledButtonContent(
            label: AnyView(label),
            isPressed: isPressed
        )

        if isEnabled {
            styled
                .focused($isFocused)
                .onKeyDown(.enter) { _ in
                    guard isFocused else { return }
                    isPressed = true
                    action()
                    Task { @MainActor in
                        try? await Task.sleep(for: .milliseconds(80))
                        isPressed = false
                    }
                }
        } else {
            styled
        }
    }
}

extension Button where Label == Text {
    /// Creates a button with a text label.
    ///
    /// - Parameters:
    ///   - title: The string to display as the button's label.
    ///   - action: The closure to run when the button is pressed.
    public init(
        _ title: String,
        action: @escaping @MainActor () -> Void
    ) {
        self.action = action
        self.label = Text(title)
    }
}

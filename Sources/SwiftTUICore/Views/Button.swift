//
//  Button.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Terminal

public struct Button<Label: View>: View {
    private let action: @MainActor () -> Void
    private let label: Label

    @State private var isFocused: Bool = false
    @State private var isPressed: Bool = false

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.buttonStyle) private var buttonStyle

    public init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        let configuration = ButtonStyleConfiguration(
            label: .init(label),
            isPressed: isPressed
        )
        let styled = buttonStyle.makeBody(configuration)

        if isEnabled {
            styled
                .focused($isFocused)
                .onKeyDown(.enter) { _ in
                    guard isFocused else { return }
                    isPressed = true
                    action()
                }
                .onKeyUp(.enter) { _ in
                    isPressed = false
                }
        } else {
            styled
        }
    }
}

extension Button where Label == Text {
    public init(
        _ title: String,
        action: @escaping @MainActor () -> Void
    ) {
        self.action = action
        self.label = Text(title)
    }
}

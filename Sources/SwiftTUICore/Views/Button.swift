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
    @Environment(\.isEnabled) private var isEnabled

    public init(
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.action = action
        self.label = label()
    }

    public var body: some View {
        let showFocusMarker = isEnabled && isFocused
        let content = HStack {
            Text(showFocusMarker ? ">" : " ")
            label
            Text(showFocusMarker ? "<" : " ")
        }

        if isEnabled {
            content
                .focused($isFocused)
                .onKeyPressed(.enter) { _ in
                    guard isFocused else { return }
                    action()
                }
        } else {
            content
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

//
//  ButtonStyleConfiguration.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

/// The label and state of a button, passed to a ``ButtonStyle``.
public struct ButtonStyleConfiguration {
    /// A view of the button's label.
    public let label: Label
    /// A Boolean value that is `true` while the button is being activated.
    public let isPressed: Bool

    init(label: AnyView, isPressed: Bool) {
        self.label = Label(content: label)
        self.isPressed = isPressed
    }
}

extension ButtonStyleConfiguration {
    public struct Label: View {
        let content: AnyView

        nonisolated init(content: AnyView) {
            self.content = content
        }

        public var body: some View {
            content
        }
    }
}

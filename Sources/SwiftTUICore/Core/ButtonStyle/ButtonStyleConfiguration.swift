//
//  ButtonStyleConfiguration.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

public struct ButtonStyleConfiguration {
    public let label: Label
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

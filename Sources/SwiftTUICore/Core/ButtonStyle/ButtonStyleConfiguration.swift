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

    init(label: Label, isPressed: Bool) {
        self.label = label
        self.isPressed = isPressed
    }
}

extension ButtonStyleConfiguration {
    public struct Label: View {
        let content: AnyView

        init<V: View>(_ view: V) {
            self.content = AnyView(view)
        }

        public var body: some View {
            content
        }
    }
}

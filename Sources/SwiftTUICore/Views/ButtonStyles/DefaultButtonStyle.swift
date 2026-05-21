//
//  DefaultButtonStyle.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

public struct DefaultButtonStyle: ButtonStyle {
    @Environment(\.isFocused) private var isFocused

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            Text(isFocused ? ">" : " ")
            configuration.label
            Text(isFocused ? "<" : " ")
        }
    }
}

public extension ButtonStyle where Self == DefaultButtonStyle {
    static var `default`: some ButtonStyle {
        DefaultButtonStyle()
    }
}

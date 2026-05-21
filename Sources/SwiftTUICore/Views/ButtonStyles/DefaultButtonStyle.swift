//
//  DefaultButtonStyle.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation

public struct DefaultButtonStyle: ButtonStyle {
    public nonisolated init() {}

    public func makeBody(configuration: Configuration) -> some View {
        DefaultButtonStyleBody(configuration: configuration)
    }
}

private struct DefaultButtonStyleBody: View {
    let configuration: ButtonStyleConfiguration

    @Environment(\.isFocused) private var isFocused

    var body: some View {
        HStack {
            Text(isFocused ? ">" : " ")
            configuration.label
            Text(isFocused ? "<" : " ")
        }
    }
}

//
//  RenderingConfiguration.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 17/03/2026.
//

import Foundation

@_documentation(visibility: internal)
public struct RenderingConfiguration: Sendable {
    public let emptyChar: Character
    public let lineJoinSeparator: String
    public let renderColor: Bool

    public init(
        emptyChar: Character,
        lineJoinSeparator: String,
        renderColor: Bool
    ) {
        self.emptyChar = emptyChar
        self.lineJoinSeparator = lineJoinSeparator
        self.renderColor = renderColor
    }
}

extension RenderingConfiguration {
    public static let standard: Self = .init(
        emptyChar: " ",
        lineJoinSeparator: "",
        renderColor: true
    )

    /// Offline-friendly variant: rows are joined by `\n` so the result can be
    /// printed directly without cursor escape codes (used by `renderToANSI`).
    public static let offline: Self = .init(
        emptyChar: " ",
        lineJoinSeparator: "\n",
        renderColor: true
    )
}

//
//  RenderingConfiguration.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 17/03/2026.
//

import Foundation

struct RenderingConfiguration {
    let emptyChar: Character
    let lineJoinSeparator: String
    let renderColor: Bool

    init(
        emptyChar: Character,
        lineJoinSeparator: String,
        renderColor: Bool
    ) {
        self.emptyChar = emptyChar
        self.lineJoinSeparator = lineJoinSeparator
        self.renderColor = renderColor
    }
}

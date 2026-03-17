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

    init(
        emptyChar: Character,
        lineJoinSeparator: String
    ) {
        self.emptyChar = emptyChar
        self.lineJoinSeparator = lineJoinSeparator
    }
}

//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import Geometry
import Terminal

nonisolated struct TerminalBufferCell: Sendable {
    var character: Character
    var foregroundColor: ANSIColor = .default
    var backgroundColor: ANSIColor = .default

    init(_ character: Character) {
        self.character = character
    }

    mutating func setCharacter(_ character: Character) {
        self.character = character
    }

    mutating func setForegroundColor(_ color: ANSIColor) {
        self.foregroundColor = color
    }

    mutating func setBackgroundColor(_ color: ANSIColor) {
        self.backgroundColor = color
    }

    func stringValue(includeColors: Bool = true) -> String {
        if includeColors {
            "\(foregroundColor.foregroundCode)\(backgroundColor.backgroundCode)\(character)\(ANSIColor.default.foregroundCode)\(ANSIColor.default.backgroundCode)"
        } else {
            String(character)
        }
    }
}

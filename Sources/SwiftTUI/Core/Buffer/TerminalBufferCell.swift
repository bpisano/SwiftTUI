//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import Geometry
import Terminal

struct TerminalBufferCell: Sendable {
    private var character: Character
    private var foregroundColor: ANSIColor = .default
    private var backgroundColor: ANSIColor = .default

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

    func stringValue() -> String {
        "\(foregroundColor.foregroundCode)\(backgroundColor.backgroundCode)\(character)\(ANSIColor.default.foregroundCode)\(ANSIColor.default.backgroundCode)"
    }
}

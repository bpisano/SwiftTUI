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
    private var character: Character = " "
    private var foregroundColor: ANSIColor = .default
    private var backgroundColor: ANSIColor = .default

    mutating func setCharacter(_ character: Character) {
        self.character = character
    }

    func stringValue(emptyChar: Character = " ") -> String {
        let displayChar: Character = character == " " ? emptyChar : character
        return "\(displayChar)"
        //        "\(foregroundColor.foregroundCode)\(backgroundColor.backgroundCode)\(character)\(ANSIColor.default.foregroundCode)\(ANSIColor.default.backgroundCode)"
    }
}

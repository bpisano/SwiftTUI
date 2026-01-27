//
//  PutCharCommand.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry

struct PutCharCommand: DrawCommand {
    let char: Character

    func draw(in rect: Rect) {

    }
}

extension DrawCommand where Self == PutCharCommand {
    static func putChar(_ char: Character) -> PutCharCommand {
        PutCharCommand(char: char)
    }
}

//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 25/11/2025.
//

import Foundation
import Geometry

struct PutLineCommand: DrawCommand {
    let line: String

    func draw(in rect: Rect) {

    }
}

extension DrawCommand where Self == PutLineCommand {
    static func putLine(_ line: String) -> PutLineCommand {
        PutLineCommand(line: line)
    }
}

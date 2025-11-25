//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry

struct DisplayList {
    let commands: [Command]
}

extension DisplayList {
    struct Command {
        let frame: Rect
        let drawCommand: DrawCommand

        init(_ drawCommand: DrawCommand, in frame: Rect) {
            self.frame = frame
            self.drawCommand = drawCommand
        }

        func draw() {
            drawCommand.draw(in: frame)
        }
    }
}

extension DisplayList: CustomStringConvertible {
    var description: String {
        "\(commands.map { "\($0.drawCommand) in \($0.frame)" }.joined(separator: "<br />"))"
    }
}

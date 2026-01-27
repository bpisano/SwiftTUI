//
//  DrawCommand.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry

public enum DrawCommand: Sendable {
    case putLine(_ line: String)
}

extension DrawCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .putLine(let line):
            "PutLine(\(line))"
        }
    }
}

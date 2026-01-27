//
//  DrawCommand.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import Geometry

protocol DrawCommand {
    func draw(in rect: Rect)
}

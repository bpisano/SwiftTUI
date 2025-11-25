//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 24/11/2025.
//

import Foundation
import Geometry

struct ViewGeometry {
    static let zero: ViewGeometry = .init(frame: .zero)

    let frame: Rect
}

extension ViewGeometry: CustomStringConvertible {
    var description: String {
        frame.description
    }
}

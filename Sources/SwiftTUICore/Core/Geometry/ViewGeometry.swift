//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 24/11/2025.
//

import Foundation
import Geometry

struct ViewGeometry {
    static let zero: ViewGeometry = .init(dimensions: .zero)

    let dimensions: ViewDimensions
}

extension ViewGeometry: CustomStringConvertible {
    var description: String {
        dimensions.description
    }
}

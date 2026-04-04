//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import Foundation

public protocol AlignmentID: Sendable {
    static func defaultValue(in context: ViewDimensions) -> Double
}

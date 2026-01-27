//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 15/12/2025.
//

import Foundation

extension Double {
    func clamped(_ minValue: Double, _ maxValue: Double) -> Double {
        min(max(self, minValue), maxValue)
    }
}
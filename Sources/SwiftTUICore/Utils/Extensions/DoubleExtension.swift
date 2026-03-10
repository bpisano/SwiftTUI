//
//  DoubleExtension.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry

extension GeometryUnit {
    func clamped(
        _ minValue: GeometryUnit,
        _ maxValue: GeometryUnit
    ) -> GeometryUnit {
        min(max(self, minValue), maxValue)
    }
}

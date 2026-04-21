//
//  PrimitiveShapeStyle.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 14/04/2026.
//

import Foundation

protocol PrimitiveShapeStyle: ShapeStyle, Sendable where Style == Self {}

extension PrimitiveShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> Self {
        self
    }
}

extension Never: ShapeStyle {
    public func resolve(in environment: EnvironmentValues) -> Never {
        fatalError("Never can never be resolved")
    }
}

//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation
import Geometry

public protocol ShapeStyle: Sendable {
    associatedtype Style: ShapeStyle

    static func makeShapeStyle(
        _ shapeStyle: Self,
        inputs: ShapeStyleInputs,
    ) -> ShapeStyleOutputs

    func resolve(in environment: EnvironmentValues) -> Self.Style
}

extension ShapeStyle {
    public static func makeShapeStyle(
        _ shapeStyle: Self,
        inputs: ShapeStyleInputs
    ) -> ShapeStyleOutputs {
        let resolvedShapeStyle: Style = shapeStyle.resolve(in: inputs.environment)
        return Style.makeShapeStyle(resolvedShapeStyle, inputs: inputs)
    }
}

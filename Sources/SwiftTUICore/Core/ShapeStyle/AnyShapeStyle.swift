//
//  AnyShapeStyle.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 14/04/2026.
//

import Foundation

public struct AnyShapeStyle: ShapeStyle {
    private let _makeShapeStyle: (ShapeStyleInputs) -> ShapeStyleOutputs
    private let _resolve: (EnvironmentValues) -> AnyShapeStyle

    public init<S: ShapeStyle>(_ shapeStyle: S) {
        self._makeShapeStyle = { inputs in
            S.makeShapeStyle(shapeStyle, inputs: inputs)
        }
        self._resolve = { environment in
            AnyShapeStyle(shapeStyle.resolve(in: environment))
        }
    }
}

extension AnyShapeStyle {
    public static func makeShapeStyle(
        _ shapeStyle: AnyShapeStyle,
        inputs: ShapeStyleInputs
    ) -> ShapeStyleOutputs {
        shapeStyle._makeShapeStyle(inputs)
    }

    public func resolve(in environment: EnvironmentValues) -> AnyShapeStyle {
        _resolve(environment)
    }
}

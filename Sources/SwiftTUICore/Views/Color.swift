//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 18/03/2026.
//

import Foundation
import Geometry
import AttributeGraph
import Terminal

public struct Color: View, PrimitiveView {
    private let ansiColor: ANSIColor

    public nonisolated init(_ ansiColor: ANSIColor) {
        self.ansiColor = ansiColor
    }

    public nonisolated init(
        red: Float,
        green: Float,
        blue: Float
    ) {
        self.ansiColor = .rgb(
            r: UInt8(red),
            g: UInt8(green),
            b: UInt8(blue)
        )
    }
}

extension Color {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let layoutComputer = Attribute("Color Layout Computer") {
            LayoutComputer { proposedSize in
                proposedSize.replacingUnspecifiedDimensions()
            } viewGeometries: { rect in
                [rect]
            }
        }

        let displayList = Attribute("Color DisplayList") {
            let ansiColor: ANSIColor = view.wrappedValue.ansiColor
            let layoutComputer: LayoutComputer = layoutComputer.wrappedValue
            let colorGeometries: [ViewGeometry] = layoutComputer.viewGeometries(inputs.frame)
            let colorGeometry: ViewGeometry = colorGeometries[0]
            let command: DisplayList.Command = .init(
                .backgroundColor(ansiColor),
                in: colorGeometry
            )
            return DisplayList(commands: [command])
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    public static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .unaryViewListOutputs("Color ViewList", implicitId: inputs.implicitId) { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }
}

extension Color: ShapeStyle, PrimitiveShapeStyle {
    public static nonisolated func makeShapeStyle(
        _ shapeStyle: Color,
        inputs: ShapeStyleInputs
    ) -> ShapeStyleOutputs {
        let commands: [DisplayList.Command] = [
            .init(.foregroundColor(shapeStyle.ansiColor), in: inputs.rect)
        ]
        return .init(commands: commands)
    }
}

extension Color: Equatable {}
extension Color: Hashable {}
extension Color: Codable {}
extension Color: Sendable {}

extension ShapeStyle where Self == Color {
    // MARK: - Styles

    public static var primary: Self { .init(.white) }
    public static var secondary: Self { .init(red: 0.87, green: 0.87, blue: 0.87) }
    public static var tertiary: Self { .init(red: 0.63, green: 0.63, blue: 0.63) }

    // MARK: - Colors

    public static var black: Self { .init(.black) }
    public static var red: Self { .init(.red) }
    public static var green: Self { .init(.green) }
    public static var yellow: Self { .init(.yellow) }
    public static var blue: Self { .init(.blue) }
    public static var magenta: Self { .init(.magenta) }
    public static var cyan: Self { .init(.cyan) }
    public static var white: Self { .init(.white) }
}

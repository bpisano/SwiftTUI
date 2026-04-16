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
            r: UInt8(red * 255),
            g: UInt8(green * 255),
            b: UInt8(blue * 255)
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

// MARK: - Static colors

extension Color {
    public nonisolated static let black: Color = .init(.black)
    public nonisolated static let red: Color = .init(.red)
    public nonisolated static let green: Color = .init(.green)
    public nonisolated static let yellow: Color = .init(.yellow)
    public nonisolated static let blue: Color = .init(.blue)
    public nonisolated static let magenta: Color = .init(.magenta)
    public nonisolated static let cyan: Color = .init(.cyan)
    public nonisolated static let white: Color = .init(.white)
    public nonisolated static let gray: Color = .init(.gray)
    public nonisolated static let softBlack: Color = .init(.softBlack)
    public nonisolated static let softRed: Color = .init(.softRed)
    public nonisolated static let softGreen: Color = .init(.softGreen)
    public nonisolated static let softYellow: Color = .init(.softYellow)
    public nonisolated static let softBlue: Color = .init(.softBlue)
    public nonisolated static let softMagenta: Color = .init(.softMagenta)
    public nonisolated static let softCyan: Color = .init(.softCyan)
    public nonisolated static let softWhite: Color = .init(.softWhite)
}

// MARK: - ShapeStyle

extension ShapeStyle where Self == Color {
    public static var primary: Self { .white }
    public static var secondary: Self { .softWhite }
    public static var tertiary: Self { .init(red: 0.6, green: 0.6, blue: 0.6) }
    public static var quaternary: Self { .init(red: 0.4, green: 0.4, blue: 0.4) }
    public static var quinary: Self { .init(red: 0.3, green: 0.3, blue: 0.3) }

    public static var black: Self { .black }
    public static var red: Self { .red }
    public static var green: Self { .green }
    public static var yellow: Self { .yellow }
    public static var blue: Self { .blue }
    public static var magenta: Self { .magenta }
    public static var cyan: Self { .cyan }
    public static var white: Self { .white }
    public static var gray: Self { .gray }
    public static var softBlack: Self { .softBlack }
    public static var softRed: Self { .softRed }
    public static var softGreen: Self { .softGreen }
    public static var softYellow: Self { .softYellow }
    public static var softBlue: Self { .softBlue }
    public static var softMagenta: Self { .softMagenta }
    public static var softCyan: Self { .softCyan }
    public static var softWhite: Self { .softWhite }
}

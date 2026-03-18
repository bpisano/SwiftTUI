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

    public init(_ ansiColor: ANSIColor) {
        self.ansiColor = ansiColor
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

            var x: GeometryUnit = colorGeometry.origin.x
            var y: GeometryUnit = colorGeometry.origin.y
            var commands: [DisplayList.Command] = []

            for _ in 0..<Int(colorGeometry.size.height) {
                for _ in 0..<Int(colorGeometry.size.width) {
                    let origin: Point = .init(x: x, y: y)
                    let size: Size = .init(width: 1, height: 1)
                    let commandFrame: Rect = .init(origin: origin, size: size)
                    let command: DisplayList.Command = .init(
                        .backgroundColor(ansiColor),
                        in: commandFrame
                    )
                    commands.append(command)
                    x += 1
                }
                x = colorGeometry.origin.x
                y += 1
            }

            return DisplayList(commands: commands)
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
        .unaryViewListOutputs("Color ViewList") { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }
}

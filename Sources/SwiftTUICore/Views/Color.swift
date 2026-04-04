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
        .unaryViewListOutputs("Color ViewList") { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }
}

extension Color: Equatable {}
extension Color: Hashable {}
extension Color: Codable {}
extension Color: Sendable {}

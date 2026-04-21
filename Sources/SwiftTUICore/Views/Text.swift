//
//  Text.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import AttributeGraph
import Foundation
import Geometry

public struct Text: View, PrimitiveView {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }
}

extension Text {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let layoutComputer = Attribute("Text Layout Computer") {
            let text: String = view.wrappedValue.text
            return LayoutComputer { proposedSize in
                let lines: [String] =
                    if let proposedWidth = proposedSize.width {
                        text.slice(Int(proposedWidth))
                    } else {
                        [text]
                    }
                let maxWidth = lines.reduce(0) { max($0, $1.count) }
                return Size(
                    width: Double(maxWidth),
                    height: Double(lines.count)
                )
            } viewGeometries: { rect in
                [rect]
            }
        }

        let displayList = Attribute("Text DisplayList") {
            let layoutComputer: LayoutComputer = layoutComputer.wrappedValue
            let textGeometries: [ViewGeometry] = layoutComputer.viewGeometries(inputs.frame)
            let textGeometry: ViewGeometry = textGeometries[0]

            let text: String = view.wrappedValue.text
            let lines: [String] = text.slice(Int(textGeometry.width))
            let textCommands: [DisplayList.Command] = lines.enumerated().map { index, line in
                let origin: Point = .init(
                    x: textGeometry.x,
                    y: textGeometry.y + GeometryUnit(index)
                )
                let size: Size = .init(width: textGeometry.width, height: 1)
                let commandFrame: Rect = .init(origin: origin, size: size)
                return DisplayList.Command(
                    .putLine(line),
                    in: commandFrame
                )
            }

            let environment: EnvironmentValues = inputs.environment.wrappedValue
            let foregroundStyle: AnyShapeStyle = environment[keyPath: \.foregroundStyle]
            let shapeStyleOutputs: ShapeStyleOutputs = AnyShapeStyle.makeShapeStyle(
                foregroundStyle,
                inputs: .init(
                    rect: textGeometry,
                    environment: environment
                )
            )
            let shapeStyleCommands: [DisplayList.Command] = shapeStyleOutputs.commands

            return DisplayList(commands: textCommands + shapeStyleCommands)
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
        .unaryViewListOutputs("Text ViewList", implicitId: inputs.implicitId) { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }
}

extension Text: Equatable {}
extension Text: Hashable {}
extension Text: Codable {}
extension Text: Sendable {}

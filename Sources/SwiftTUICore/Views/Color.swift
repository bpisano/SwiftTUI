//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import AttributeGraph
import Geometry

public struct Color: UnaryView, PrimitiveView {
    private let name: Character

    public init(_ name: Character) {
        self.name = name
    }
}

extension Color {
    public static func makeView(_ view: Attribute<Color>, inputs: ViewInputs) -> ViewOutputs {
        let layoutComputer = Attribute {
            LayoutComputer { proposal in
                return proposal.replacingUnspecifiedDimensions()
            } childGeometries: { rect in
                let dimensions: ViewDimensions = .init(frame: rect)
                return [ViewGeometry(dimensions: dimensions)]
            }
        }

        let colorCharacter = Attribute {
            view.wrappedValue.name
        }

        let colorGeometry = Attribute {
            let computer = layoutComputer.wrappedValue
            let proposal = ProposedViewSize(inputs.size.wrappedValue)
            let size = computer.sizeThatFits(proposal)
            return computer.childGeometries(
                in: .init(origin: .zero, size: size)
            )[0]
        }

        let displayList = Attribute {
            let character = colorCharacter.wrappedValue
            let colorGeometry = colorGeometry.wrappedValue

            var items: [DisplayList.Item] = []
            for y in 0..<Int(colorGeometry.dimensions.size.height) {
                let lineString = String(
                    repeating: character,
                    count: Int(colorGeometry.dimensions.size.width)
                )
                items.append(.init(
                    content: .command(.putLine(lineString)),
                    frame: .init(
                        x: colorGeometry.dimensions.origin.x,
                        y: colorGeometry.dimensions.origin.y + Double(y),
                        width: colorGeometry.dimensions.size.width,
                        height: 1
                    )
                ))
            }

            return DisplayList(items)
        }

        layoutComputer.label = "Color Layout Computer"
        colorGeometry.label = "Color Geometry"
        displayList.label = "Color Display List"
        colorCharacter.label = "Color Character"

        return ViewOutputs(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }
}

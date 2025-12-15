//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import AttributeGraph
import Geometry

struct Color: UnaryView {
    private let name: Character

    init(_ name: Character) {
        self.name = name
    }
}

extension Color {
    static func makeView(_ view: Attribute<Color>, inputs: ViewInputs) -> ViewOutputs {
        let layoutComputer = Attribute {
            LayoutComputer { proposal in
                print("Color proposal:", proposal)
                return proposal.replacingUnspecifiedDimensions()
            } childGeometries: { rect in
                print("Color childGeometries rect:", rect)
                let dimensions: ViewDimensions = .init(frame: rect)
                return [ViewGeometry(dimensions: dimensions)]
            }
        }

        let colorCharacter = Attribute {
            view.wrappedValue.name
        }

        let displayList = Attribute {
            print("--- Color displayList computation ---")
            let character = colorCharacter.wrappedValue
            let colorGeometry = layoutComputer.wrappedValue.childGeometries(
                in: inputs.frame.wrappedValue
            )[0]
            print("Color geometry:", colorGeometry)

            var items: [DisplayList.Item] = []
            for y in 0..<Int(colorGeometry.dimensions.size.height) {
                let lineString: String = String(
                    repeating: character,
                    count: Int(colorGeometry.dimensions.size.width)
                )
                let command: DrawCommand = .putLine(lineString)
                let item: DisplayList.Item = .init(
                    content: .command(command),
                    frame: .init(
                        x: 0,
                        y: Double(y),
                        width: colorGeometry.dimensions.size.width,
                        height: 1
                    )
                )
                items.append(item)
            }

            return DisplayList(items)
        }

        layoutComputer.label = "Color Layout Computer"
        displayList.label = "Color Display List"
        colorCharacter.label = "Color Character"

        return ViewOutputs(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }
}

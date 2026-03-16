//
//  ExpandingView.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 16/03/2026.
//

import Foundation
import AttributeGraph
import Geometry
@testable import SwiftTUI
@testable import SwiftTUICore

struct ExpandingView: View, PrimitiveView {
    let char: Character
}

extension ExpandingView {
    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let layoutComputer = Attribute("ExpandingView Layout Computer") {
            LayoutComputer { proposedSize in
                // Expands to fill available space
                proposedSize.replacingUnspecifiedDimensions()
            } viewGeometries: { rect in
                [rect]
            }
        }

        let displayList = Attribute("ExpandingView DisplayList") {
            let layoutComputer: LayoutComputer = layoutComputer.wrappedValue
            let geometries: [ViewGeometry] = layoutComputer.viewGeometries(
                Rect(origin: .zero, size: inputs.size.wrappedValue)
            )
            let geometry: ViewGeometry = geometries[0]
            let char: Character = view.wrappedValue.char
            let inputPosition: Point = inputs.position.wrappedValue

            return DisplayList(
                commands: (0..<Int(geometry.height)).map { row in
                    let line = String(repeating: char, count: Int(geometry.width))
                    let origin = Point(x: inputPosition.x, y: inputPosition.y + Double(row))
                    let size = Size(width: geometry.width, height: 1)
                    return DisplayList.Command(
                        .putLine(line),
                        in: Rect(origin: origin, size: size)
                    )
                }
            )
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .unaryViewListOutputs("ExpandingView ViewList") { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }
}

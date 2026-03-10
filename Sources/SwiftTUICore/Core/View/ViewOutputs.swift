//
//  ViewOutputs.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry
import AttributeGraph

public struct ViewOutputs {
    public let displayList: Attribute<DisplayList>

    let layoutComputer: Attribute<LayoutComputer>

    init(
        layoutComputer: Attribute<LayoutComputer>,
        displayList: Attribute<DisplayList>
    ) {
        self.layoutComputer = layoutComputer
        self.displayList = displayList
    }
}

extension ViewOutputs {
    /// Creates `ViewOutputs` for a view that contains multiple child views, by combining the outputs of its children.
    ///
    /// - Parameters:
    ///   - inputs: The `ViewInputs` for the parent view.
    ///   - makeViewListOutputs: A closure that takes `ViewListInputs` and returns `ViewListOutputs` for the child views.
    ///   - Returns: A `ViewOutputs` instance that combines the outputs of the child views.
    static func unaryViewOutputs(
        inputs: ViewInputs,
        makeViewListOutputs: (ViewListInputs) -> ViewListOutputs,
    ) -> ViewOutputs {
        let viewListInputs: ViewListInputs = .init(viewInputs: inputs)
        let viewListOutputs: ViewListOutputs = makeViewListOutputs(viewListInputs)
        let viewList: Attribute<any ViewList> = viewListOutputs.viewList
        let childOutputs: [ViewOutputs] = viewList.wrappedValue.makeViewOutputs(inputs: inputs)
        return .combineViewOutputs(childOutputs)
    }

    private static func combineViewOutputs(_ viewOutputs: [ViewOutputs]) -> ViewOutputs {
        guard !viewOutputs.isEmpty else {
            fatalError("Cannot combine an empty array of ViewOutputs")
        }

        let combinedLayoutComputer = Attribute {
            LayoutComputer { proposal in
                let childSizes: [Size] = viewOutputs.map {
                    $0.layoutComputer.wrappedValue.sizeThatFits(proposal)
                }
                let totalHeight: GeometryUnit = childSizes.reduce(0.0) { $0 + $1.height }
                let maxWidth: GeometryUnit = childSizes.map(\.width).max() ?? 0
                return .init(width: maxWidth, height: totalHeight)
            } viewGeometries: { rect in
                var currentY: Double = rect.origin.y
                return viewOutputs.enumerated().flatMap { index, output in
                    let childSize: Size = output.layoutComputer.wrappedValue.sizeThatFits(
                        .init(width: rect.size.width, height: nil)
                    )
                    let childRect: Rect = .init(
                        origin: Point(x: rect.origin.x, y: currentY),
                        size: childSize
                    )
                    currentY += childSize.height
                    return output.layoutComputer.wrappedValue.viewGeometries(childRect)
                }
            }
        }

        let combinedDisplayList = Attribute {
            DisplayList(viewOutputs.flatMap { $0.displayList.wrappedValue.items })
        }

        return ViewOutputs(
            layoutComputer: combinedLayoutComputer,
            displayList: combinedDisplayList
        )
    }
}

extension ViewOutputs: AttributeValueRepresentable {
    public var attributeValueDescription: String {
        "ViewOutputs"
    }
}

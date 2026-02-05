//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/12/2025.
//

import AttributeGraph
import Foundation
import Geometry

struct FrameModifier: UnaryViewModifier, PrimitiveViewModifier {
    private let width: Double?
    private let height: Double?
    private let alignment: Alignment

    init(
        width: Double? = nil,
        height: Double? = nil,
        alignment: Alignment = .center
    ) {
        self.width = width
        self.height = height
        self.alignment = alignment
    }
}

extension FrameModifier {
    static func makeView(
        _ modifier: Attribute<FrameModifier>,
        inputs: ViewInputs,
        body: @escaping (ViewInputs) -> ViewOutputs
    ) -> ViewOutputs {
        var layoutComputer: Attribute<LayoutComputer>!

        let modifiedPosition = Attribute {
            let inputFrame: Rect = inputs.frame
            let childGeometry: ViewGeometry = layoutComputer.wrappedValue.childGeometries(
                in: inputFrame
            )[0]

            return childGeometry.dimensions.origin
        }

        let modifiedSize = Attribute {
            let inputFrame: Rect = inputs.frame
            let childGeometry: ViewGeometry = layoutComputer.wrappedValue.childGeometries(
                in: inputFrame
            )[0]

            var childGeometrySize: Size = childGeometry.dimensions.frame.size
            childGeometrySize.width = childGeometrySize.width.clamped(0, inputFrame.size.width)
            childGeometrySize.height = childGeometrySize.height.clamped(0, inputFrame.size.height)

            return childGeometrySize
        }

        let modifiedInputs: ViewInputs = .init(
            position: modifiedPosition,
            size: modifiedSize,
            phase: inputs.phase,
            storage: inputs.storage
        )
        let childOutputs: ViewOutputs = body(modifiedInputs)

        layoutComputer = Attribute {
            let modifier = modifier.wrappedValue
            let frameLayout: FrameLayout = .init(
                width: modifier.width,
                height: modifier.height,
                alignment: modifier.alignment
            )
            return frameLayout.layoutComputer(for: [childOutputs.layoutComputer.wrappedValue])
        }

        layoutComputer.label = "FrameModifier Layout Computer"
        modifiedSize.label = "FrameModifier Modified Size"
        modifiedPosition.label = "FrameModifier Modified Position"

        return ViewOutputs(
            layoutComputer: layoutComputer,
            displayList: childOutputs.displayList
        )
    }
}

extension FrameModifier {
    private static func combineDisplayLists(
        childDisplayLists: [DisplayList],
        childGeometries: [ViewGeometry]
    ) -> DisplayList {
        // Create displayList for each child
        var items: [DisplayList.Item] = []
        for (index, childDisplayList) in childDisplayLists.enumerated() {
            let childGeometry: ViewGeometry = childGeometries[index]
            let item: DisplayList.Item = .init(
                content: .childList(childDisplayList),
                frame: childGeometry.dimensions.frame
            )
            items.append(item)
        }

        // Create container displayList
        return DisplayList(items)
    }
}

extension View {
    func frame(
        width: Double? = nil,
        height: Double? = nil,
        alignment: Alignment = .center
    ) -> some View {
        modifier(
            FrameModifier(
                width: width,
                height: height,
                alignment: alignment
            )
        )
    }
}

extension FrameModifier: CustomStringConvertible {
    var description: String {
        "(\(width, default: "nil"), \(height, default: "nil"), \(alignment))"
    }
}

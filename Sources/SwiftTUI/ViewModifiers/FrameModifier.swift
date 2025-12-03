//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/12/2025.
//

import AttributeGraph
import Foundation
import Geometry

struct FrameModifier: ViewModifier {
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
        // Create forward reference for the frame layout computer
        var frameLayoutComputer: Attribute<LayoutComputer>!

        // Create child geometry that will be computed from the frame layout
        let childGeometry: Attribute<ViewGeometry> = Attribute {
            let frameLayoutComputer: LayoutComputer = frameLayoutComputer.wrappedValue
            let proposal: ProposedViewSize = .init(inputs.proposalFrame.wrappedValue.size)
            let containerSize: Size = frameLayoutComputer.sizeThatFits(proposal)
            let geometries = frameLayoutComputer.childGeometries(
                in: .init(origin: .zero, size: containerSize))
            return geometries[0]
        }
        childGeometry.label = "FrameModifier Child Geometry"

        // Pass modified inputs with only the computed geometry to the child
        let childInputs = ViewInputs(geometry: childGeometry)
        let contentOutputs: ViewOutputs = body(childInputs)

        // Create frame layout computer that wraps the child's layout
        frameLayoutComputer = Attribute {
            let modifierValue: FrameModifier = modifier.wrappedValue
            let frameLayout: FrameLayout = .init(
                width: modifierValue.width,
                height: modifierValue.height,
                alignment: modifierValue.alignment
            )
            let contentLayoutComputer: LayoutComputer = contentOutputs.layoutComputer.wrappedValue
            return frameLayout.layoutComputer(for: [contentLayoutComputer])
        }
        frameLayoutComputer.label = "FrameModifier LayoutComputer"

        let displayList = Attribute {
            let geometries: [ViewGeometry] = [childGeometry.wrappedValue]
            let childDisplayList: DisplayList = contentOutputs.displayList.wrappedValue
            return combineDisplayLists(
                childDisplayLists: [childDisplayList],
                childGeometries: geometries
            )
        }
        displayList.label = "FrameModifier DisplayList"

        return ViewOutputs(
            layoutComputer: frameLayoutComputer,
            displayList: displayList
        )
    }

    static func makeViewList(
        _ modifier: Attribute<FrameModifier>,
        inputs: ViewListInputs,
        body: @escaping (ViewListInputs) -> ViewListOutputs
    ) -> ViewListOutputs {
        body(inputs)
    }

    static func viewListCount(
        inputs: ViewListCountInputs,
        body: (ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
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
    ) -> ModifiedContent<Self, FrameModifier> {
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

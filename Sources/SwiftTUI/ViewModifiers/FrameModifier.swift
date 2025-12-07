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
        let vmd = "FrameModifier \(modifier.wrappedValue.width, default: "nil")"

        print("--- START \(vmd) ---")
        print(" -- Inputs \(vmd)", inputs.frame.wrappedValue)

        let childOutputs: ViewOutputs = body(inputs)
        print("child geometries \(vmd)", childOutputs.layoutComputer.wrappedValue.childGeometries(in: inputs.frame.wrappedValue))

        let layoutComputer = Attribute {
            let modifier = modifier.wrappedValue
            let frameLayout: FrameLayout = .init(
                width: modifier.width,
                height: modifier.height,
                alignment: modifier.alignment
            )
            return frameLayout.layoutComputer(for: [childOutputs.layoutComputer.wrappedValue])
        }

        let childGeometries = Attribute {
            layoutComputer.wrappedValue.childGeometries(in: inputs.frame.wrappedValue)
        }

        print("child geometries frame \(vmd)", layoutComputer.wrappedValue.childGeometries(in: inputs.frame.wrappedValue))

        let displayList = Attribute {
            let childDisplayLists = [childOutputs.displayList.wrappedValue]
            let displayList = combineDisplayLists(
                childDisplayLists: childDisplayLists,
                childGeometries: childGeometries.wrappedValue
            )
            return displayList
        }

        print("--- END FrameModifier \(modifier.wrappedValue.width, default: "0") ---")

        layoutComputer.label = "FrameModifier Layout Computer"
        childGeometries.label = "FrameModifier Child Geometries"
        displayList.label = "FrameModifier Display List"

        return ViewOutputs(
            layoutComputer: layoutComputer,
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

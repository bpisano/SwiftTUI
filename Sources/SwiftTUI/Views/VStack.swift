//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 24/12/2025.
//

import AttributeGraph
import Foundation
import Geometry

struct VStack<Content: View>: UnaryView, PrimitiveView {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
}

extension VStack {
    static func makeView(
        _ view: Attribute<VStack<Content>>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let content = view.map(\.content)
        content.label = "\(Content.self)"

        let viewListOutputs: ViewListOutputs = Content.makeViewList(content, inputs: .init())
        let viewList: ViewList = viewListOutputs.makeViewList()

        var childLayoutComputersRef: [LayoutComputer] = []
        let layoutComputer = Attribute {
            let layout = VStackLayout()
            return layout.layoutComputer(for: childLayoutComputersRef)
        }
        layoutComputer.label = "VStackLayout Layout Computer"

        let childGeometries = Attribute {
            let computer: LayoutComputer = layoutComputer.wrappedValue
            let proposal: ProposedViewSize = .init(inputs.size.wrappedValue)
            let containerSize: Size = computer.sizeThatFits(proposal)
            return computer.childGeometries(
                in: .init(
                    origin: inputs.position.wrappedValue,
                    size: containerSize
                )
            )
        }
        childGeometries.label = "VStackLayout Child Geometries"

        let childViewOutputs = makeChildViewOutputs(
            list: viewList,
            inputs: inputs,
            childGeometries: childGeometries
        )

        // Update the reference with actual children's layout computers
        childLayoutComputersRef = childViewOutputs.map(\.layoutComputer.wrappedValue)

        let displayList = Attribute {
            let geometries: [ViewGeometry] = childGeometries.wrappedValue
            let childDisplayLists: [DisplayList] =
            childViewOutputs.map(\.displayList.wrappedValue)

            var items: [DisplayList.Item] = []
            for (index, childDisplayList) in childDisplayLists.enumerated() {
                let childGeometry: ViewGeometry = geometries[index]
                items.append(
                    .init(
                        content: .childList(childDisplayList),
                        frame: childGeometry.dimensions.frame
                    ))
            }
            return DisplayList(items)
        }
        displayList.label = "VStackLayout Display List"

        return ViewOutputs(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    private static func makeChildViewOutputs(
        list: ViewList,
        inputs: ViewInputs,
        childGeometries: Attribute<[ViewGeometry]>
    ) -> [ViewOutputs] {
        var viewOutputs: [ViewOutputs] = []
        var index = 0

        list.makeViews(from: &index, inputs: inputs) { currentIndex, parentInputs, makeView in
            let index = currentIndex
            let childInputs = ViewInputs(
                position: childGeometries.map { $0[index].dimensions.origin },
                size: childGeometries.map { $0[index].dimensions.size }
            )

            let childOutputs = makeView(childInputs)
            viewOutputs.append(childOutputs)

            return (childOutputs, true)
        }

        return viewOutputs
    }
}

extension VStack: CustomStringConvertible {
    var description: String {
        "VStack"
    }
}

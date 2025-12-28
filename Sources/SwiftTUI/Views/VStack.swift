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
        let childViewOutputs = makeChildViewOutputs(list: viewList, inputs: inputs)

        return makeLayoutOutputs(
            childViewOutputs: childViewOutputs,
            inputs: inputs
        )
    }

    private static func makeLayoutOutputs(
        childViewOutputs: [ViewOutputs],
        inputs: ViewInputs
    ) -> ViewOutputs {
        let layoutComputer = Attribute {
            let childLayoutComputers: [LayoutComputer] =
                childViewOutputs
                .map(\.layoutComputer.wrappedValue)
            let layout = VStackLayout()
            return layout.layoutComputer(for: childLayoutComputers)
        }

        let childGeometries = Attribute {
            let computer: LayoutComputer = layoutComputer.wrappedValue
            let proposal: ProposedViewSize = .init(inputs.frame.wrappedValue.size)
            let containerSize: Size = computer.sizeThatFits(proposal)
            return computer.childGeometries(in: .init(origin: .zero, size: containerSize))
        }

        let displayList = Attribute {
            let geometries: [ViewGeometry] = childGeometries.wrappedValue
            let childDisplayLists: [DisplayList] =
                childViewOutputs
                .map(\.displayList.wrappedValue)

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

        layoutComputer.label = "VStackLayout Layout Computer"
        childGeometries.label = "VStackLayout Child Geometries"
        displayList.label = "VStackLayout Display List"

        return ViewOutputs(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    private static func makeChildViewOutputs(
        list: ViewList,
        inputs: ViewInputs
    ) -> [ViewOutputs] {
        var viewOutputs: [ViewOutputs] = []
        list.makeViews(from: 0, inputs: inputs) { childViewOutputs in
            viewOutputs.append(childViewOutputs)
        }
        return viewOutputs
    }
}

extension VStack: CustomStringConvertible {
    var description: String {
        "VStack"
    }
}

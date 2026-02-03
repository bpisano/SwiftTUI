//
//  LayoutView.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/01/2026.
//

import Foundation
import AttributeGraph
import Geometry

protocol LayoutView: View {
    associatedtype L: Layout
    associatedtype Content: View

    var layout: L { get }
    var content: Content { get }
}

extension LayoutView {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let content = view.map(\.content)
        content.label = "\(Content.self)"

        let viewListOutputs: ViewListOutputs = Content.makeViewList(content, inputs: .init())
        let viewList: ViewList = viewListOutputs.makeViewList()

        var childOutputs: [ViewOutputs] = []
        let layout: L = view.wrappedValue.layout
        let layoutComputer = Attribute {
            layout.layoutComputer(for: childOutputs.map(\.layoutComputer.wrappedValue))
        }
        layoutComputer.label = "\(type(of: Self.self)) Layout Computer"

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
        childGeometries.label = "\(L.self) Child Geometries"

        childOutputs = makeChildViewOutputs(
            list: viewList,
            inputs: inputs,
            childGeometries: childGeometries
        )

        let displayList = Attribute {
            let geometries: [ViewGeometry] = childGeometries.wrappedValue
            let childDisplayLists: [DisplayList] =
            childOutputs.map(\.displayList.wrappedValue)

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
        displayList.label = "\(Self.self) Display List"

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
            let childGeometry = childGeometries.map { [currentIndex] geometry in
                geometry[currentIndex]
            }
            childGeometry.label = "\(L.self) Child \(currentIndex) Geometry"

            let childInputs = ViewInputs(
                position: childGeometry.map(\.dimensions.origin),
                size: childGeometry.map(\.dimensions.size),
                phase: parentInputs.phase,
                storage: parentInputs.storage
            )

            let childOutputs = makeView(childInputs)
            viewOutputs.append(childOutputs)

            return (childOutputs, true)
        }

        return viewOutputs
    }
}

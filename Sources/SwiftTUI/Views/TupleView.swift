//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/11/2025.
//

import AttributeGraph
import Foundation
import Geometry

struct TupleView<each V: View>: PrimitiveView {
    private let content: (repeat each V)

    init(_ content: repeat each V) {
        self.content = (repeat each content)
    }
}

extension TupleView: CustomStringConvertible {
    var description: String {
        "TupleView"
    }
}

extension TupleView {
    static func makeView(
        _ view: Attribute<TupleView<repeat each V>>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let viewListOutputs: ViewListOutputs = type(of: view.wrappedValue).makeViewList(
            view, inputs: .init())
        let viewList: ViewList = viewListOutputs.makeViewList()
        let childViewOutputs: [ViewOutputs] = makeChildViewOutputs(list: viewList, inputs: inputs)

        let layoutComputer = Attribute {
            let layout: HStackLayout = .init()
            let childLayoutComputers: [LayoutComputer] = childViewOutputs.map(
                \.layoutComputer.wrappedValue)
            let hstackLayoutComputer = layout.layoutComputer(for: childLayoutComputers)
            return hstackLayoutComputer
        }

        let childGeometries = Attribute {
            let layoutComputer: LayoutComputer = layoutComputer.wrappedValue
            let proposal: ProposedViewSize = .init(inputs.proposalFrame.wrappedValue.size)
            let containerSize: Size = layoutComputer.sizeThatFits(proposal)
            return layoutComputer.childGeometries(in: .init(origin: .zero, size: containerSize))
        }

        let displayList = Attribute {
            let geometries: [ViewGeometry] = childGeometries.wrappedValue
            let childDisplayLists: [DisplayList] = childViewOutputs.map(\.displayList.wrappedValue)
            let displayList = combineDisplayLists(
                childDisplayLists: childDisplayLists,
                childGeometries: geometries
            )
            return displayList
        }

        layoutComputer.label = "TupleView Layout Computer"
        childGeometries.label = "TupleView Child Geometries"
        displayList.label = "TupleView Display List"

        return ViewOutputs(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    static func makeViewList(
        _ view: Attribute<TupleView<repeat each V>>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        var outputs: [ViewListOutputs] = []

        for child in repeat each view.wrappedValue.content {
            let attr = Attribute(wrappedValue: child)
            attr.label = "\(type(of: child))"

            let childOutputs = type(of: child).makeViewList(attr, inputs: inputs)
            outputs.append(childOutputs)
        }

        return .concat(outputs)
    }

    static func viewListCount(inputs: ViewListCountInputs) -> Int? {
        let types = (repeat each V).self
        let tupleType = TupleType(types)
        return tupleType.count
    }
}

extension TupleView {
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

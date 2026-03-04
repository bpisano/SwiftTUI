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

// MARK: - Make view

extension TupleView {
    static func makeView(
        _ view: Attribute<TupleView<repeat each V>>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let viewListOutputs: ViewListOutputs = makeViewList(view, inputs: .init(from: inputs))
        let viewList: ViewList = viewListOutputs.makeViewListAttribute().wrappedValue

        var childViewOutputs: Attribute<[ViewOutputs]>!

        let layoutComputer = Attribute {
            let vstackLayout: VStackLayout = .init(alignment: .center)
            let childLayoutComputers: [LayoutComputer] = childViewOutputs.wrappedValue.map(\.layoutComputer.wrappedValue)
            let vstackLayoutComputer = vstackLayout.layoutComputer(for: childLayoutComputers)
            return vstackLayoutComputer
        }

        let childGeometries = Attribute {
            let layoutComputer: LayoutComputer = layoutComputer.wrappedValue
            let proposal: ProposedViewSize = .init(inputs.size.wrappedValue)
            let containerSize: Size = layoutComputer.sizeThatFits(proposal)
            return layoutComputer.childGeometries(in: .init(origin: .zero, size: containerSize))
        }

        let displayList = Attribute {
            let geometries: [ViewGeometry] = childGeometries.wrappedValue
            let childDisplayLists: [DisplayList] = childViewOutputs.wrappedValue.map(\.displayList.wrappedValue)
            let displayList = combineDisplayLists(
                childDisplayLists: childDisplayLists,
                childGeometries: geometries
            )
            return displayList
        }

        childViewOutputs = Attribute {
            makeChildViewOutputs(
                list: viewList,
                inputs: inputs
            )
        }

        childViewOutputs.label = "TupleView Child View Outputs"
        layoutComputer.label = "TupleView Layout Computer"
        childGeometries.label = "TupleView Child Geometries"
        displayList.label = "TupleView Display List"

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
        var index = 0
        list.makeViews(from: &index, inputs: inputs) { index, inputs, makeView in
            let childViewOutputs = makeView(inputs)
            viewOutputs.append(childViewOutputs)
            return (childViewOutputs, true)
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

// MARK: - Make view list

extension TupleView {
    static func makeViewList(
        _ view: Attribute<TupleView<repeat each V>>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let viewTypes: (repeat each V).Type = (repeat each V).self
        let tupleType: TupleType = TupleType(viewTypes)
        var currentInputs: ViewListInputs = inputs
        var outputs: [ViewListOutputs] = []

        for index in (0..<tupleType.count) {
            guard let elementType = tupleType.type(at: index) as? any View.Type else {
                continue
            }

            let viewOutputs = makeChildViewListOutputs(
                view,
                tupleType: tupleType,
                index: index,
                viewType: elementType,
                inputs: currentInputs
            )
            currentInputs.implicitId = viewOutputs.nextImplicitId
            outputs.append(viewOutputs)
        }

        return .concat(outputs, inputs: inputs)
    }

    private static func makeChildViewListOutputs<T: View>(
        _ view: Attribute<TupleView<repeat each V>>,
        tupleType: TupleType,
        index: Int,
        viewType: T.Type,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let viewOffset: Int = tupleType.elementOffset(at: index)
        let view: Attribute<T> = view.unsafeOffset(at: viewOffset, as: viewType)
        view.label = "\(T.self)"
        return T.makeViewList(view, inputs: inputs)
    }
}

// MARK: - View list count

extension TupleView {
    static func viewListCount(inputs: ViewListCountInputs) -> Int? {
        let types = (repeat each V).self
        let tupleType = TupleType(types)
        return tupleType.count
    }
}

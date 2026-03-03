//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/03/2026.
//

import Foundation
import AttributeGraph

final class ForEachState<Data: RandomAccessCollection, ID: Hashable, Content: View> {
    var view: ForEach<Data, ID, Content>?
    var itemsByIds: [ID: Item] = [:]
    var orderedIds: [ID] = []

    func updateState(with view: ForEach<Data, ID, Content>) {
        self.view = view

        var newOrderedIds: [ID] = []
        var index: Data.Index = view.data.startIndex

        while index != view.data.endIndex {
            let element: Data.Element = view.data[index]
            let elementId: ID = element[keyPath: view.id]

            if let item = itemsByIds[elementId] {
                item.index = index
            } else {
                itemsByIds[elementId] = makeItem(
                    id: elementId,
                    index: index,
                    from: view
                )
            }

            newOrderedIds.append(elementId)
            view.data.formIndex(after: &index)
        }

        orderedIds = newOrderedIds
    }

    private func makeItem(id: ID, index: Data.Index, from view: ForEach<Data, ID, Content>) -> Item {
        let subgraph: Subgraph = .init()
        let viewList = Attribute {
            Graph.current.subgraph = subgraph
            defer { Graph.current.subgraph = nil }

            let childView = Attribute {
                view.makeChildView(view.data[index])
            }
            childView.label = "ForEach Child View for id \(id)"

            let outputs = Content.makeViewList(
                childView,
                inputs: .init(implicitId: 0)
            )
            return outputs.makeViewList()
        }

        return Item(
            id: id,
            index: index,
            viewList: viewList,
            subgraph: subgraph,
        )
    }

}

extension ForEachState {
    final class Item {
        let id: ID
        var index: Data.Index
        let viewList: Attribute<ViewList>
        let subgraph: Subgraph

        init(
            id: ID,
            index: Data.Index,
            viewList: Attribute<ViewList>,
            subgraph: Subgraph = .init()
        ) {
            self.id = id
            self.index = index
            self.viewList = viewList
            self.subgraph = subgraph
        }
    }
}

extension ForEachState: CustomStringConvertible {
    var description: String {
        "ForEachState with \(orderedIds.count) items"
    }
}

struct ForEachChild<Data: RandomAccessCollection, ID: Hashable, Content: View>: Rule {
    let state: ForEachState<Data, ID, Content>
    let id: ID

    func evaluate() -> Content {
        guard
            let view = state.view,
            let item = state.itemsByIds[id]
        else {
            fatalError("ForEach: No item found for id \(id)")
        }

        let element = view.data[item.index]
        return view.makeChildView(element)
    }
}

struct ForEachInfo<Data: RandomAccessCollection, ID: Hashable, Content: View>: Rule {
    let state: ForEachState<Data, ID, Content>
    let view: Attribute<ForEach<Data, ID, Content>>

    func evaluate() -> ForEachState<Data, ID, Content> {
        state.updateState(with: view.wrappedValue)
        return state
    }
}

struct ForEachViewListRule<Data: RandomAccessCollection, ID: Hashable, Content: View>: Rule {
    let info: Attribute<ForEachState<Data, ID, Content>>

    func evaluate() -> ViewList {
        ForEachViewList(state: info.wrappedValue)
    }
}

struct ForEachViewList<Data: RandomAccessCollection, ID: Hashable, Content: View>: ViewList {
    var count: Int {
        state.orderedIds.count
    }
    var viewIds: ViewId.Views? {
        let itemLists: [ViewList] = state.orderedIds.compactMap { id in
            state.itemsByIds[id]?.viewList.wrappedValue
        }
        return MergedViewList(itemLists).viewIds
    }

    private let state: ForEachState<Data, ID, Content>

    init(state: ForEachState<Data, ID, Content>) {
        self.state = state
    }

    func makeViews(
        from start: inout Int,
        inputs: ViewInputs,
        body: (inout Int, ViewInputs, @escaping MakeElement) -> (ViewOutputs?, Bool)
    ) {
        withoutActuallyEscaping(body) { escapingBody in
            for id in state.orderedIds {
                guard let item = state.itemsByIds[id] else { continue }
                item.viewList.wrappedValue.makeViews(from: &start, inputs: inputs, body: body)
            }
        }
    }
}

extension ForEachViewList: CustomStringConvertible {
    var description: String {
        "ForEachViewList with \(state.orderedIds.count) items"
    }
}

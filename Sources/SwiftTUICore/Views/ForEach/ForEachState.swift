//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/03/2026.
//

import Foundation
import AttributeGraph

final class ForEachState<Data: RandomAccessCollection, ID: Hashable, Content: View> {
    var view: Attribute<ForEach<Data, ID, Content>>?
    var itemsByIds: [ID: Item] = [:]
    var orderedIds: [ID] = []

    func updateState(with view: Attribute<ForEach<Data, ID, Content>>) {
        self.view = view

        let wrappedView: ForEach<Data, ID, Content> = view.wrappedValue
        var newOrderedIds: [ID] = []
        var index: Data.Index = wrappedView.data.startIndex

        while index != wrappedView.data.endIndex {
            let element: Data.Element = wrappedView.data[index]
            let elementId: ID = element[keyPath: wrappedView.id]

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
            wrappedView.data.formIndex(after: &index)
        }

        orderedIds = newOrderedIds
    }

    private func makeItem(
        id: ID,
        index: Data.Index,
        from view: Attribute<ForEach<Data, ID, Content>>
    ) -> Item {
        let subgraph: Subgraph = .init()
        return subgraph.withDependencyCapture {
            let childView = Attribute {
                let view = view.wrappedValue
                return view.makeChildView(view.data[index])
            }
            childView.label = "ForEach Child View for id \(id)"
            
            let outputs: ViewListOutputs = Content.makeViewList(
                childView,
                inputs: .init(implicitId: 0)
            )
            let viewList: Attribute<any ViewList> = outputs.makeViewListAttribute()
            
            return Item(
                id: id,
                index: index,
                viewList: viewList,
                subgraph: subgraph
            )
        }
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
            subgraph: Subgraph
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

struct ForEachViewListRule<Data: RandomAccessCollection, ID: Hashable, Content: View>: @MainActor StatefulRule {
    typealias Value = ViewList

    private let state: ForEachState<Data, ID, Content>

    @Attribute private var view: ForEach<Data, ID, Content>

    init(
        state: ForEachState<Data, ID, Content>,
        view: Attribute<ForEach<Data, ID, Content>>
    ) {
        self.state = state
        self._view = view
    }

    func update() -> ViewList {
        state.updateState(with: $view)
        return ForEachViewList(state: state)
    }
}

struct ForEachViewList<Data: RandomAccessCollection, ID: Hashable, Content: View>: ViewList {
    var count: Int {
        state.orderedIds.count
    }
    var viewIds: ViewId.Views? {
        let itemLists: [Attribute<ViewList>] = state.orderedIds.compactMap { id in
            state.itemsByIds[id]?.viewList
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
                item.subgraph.withDependencyCapture {
                    item.viewList.wrappedValue.makeViews(
                        from: &start,
                        inputs: inputs,
                        body: body
                    )
                }
            }
        }
    }
}

extension ForEachViewList: CustomStringConvertible {
    var description: String {
        "ForEachViewList with \(state.orderedIds.count) items"
    }
}

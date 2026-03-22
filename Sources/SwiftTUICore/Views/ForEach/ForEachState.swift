//
//  ForEachState.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import AttributeGraph
import Foundation

final class ForEachState<Data: RandomAccessCollection, ID: Hashable, Content: View> {
    typealias ForEachType = ForEach<Data, ID, Content>

    private(set) var orderedIds: [ID] = []
    private(set) var itemsById: [ID: Item] = [:]

    func update(
        with view: Attribute<ForEachType>,
        inputs: ViewListInputs
    ) {
        orderedIds = []

        let forEach: ForEachType = view.wrappedValue
        var index: Data.Index = forEach.data.startIndex

        while index != forEach.data.endIndex {
            let element: Data.Element = forEach.data[index]
            let id: ID = element[keyPath: forEach.id]

            if let existingItem = itemsById[id] {
                existingItem.index = index
            } else {
                let item: Item = makeCachedItem(
                    for: id,
                    at: index,
                    view: view,
                    inputs: inputs
                )
                itemsById[id] = item
            }

            orderedIds.append(id)

            forEach.data.formIndex(after: &index)
        }

        let currentIds: Set<ID> = Set(orderedIds)
        let existingIds: Set<ID> = Set(itemsById.keys)
        let idsToRemove: Set<ID> = existingIds.subtracting(currentIds)
        for idToRemove in idsToRemove {
            guard let itemToRemove: Item = itemsById[idToRemove] else { continue }
            itemToRemove.viewSubgraph.clean()
            itemToRemove.viewOutputsSubgraph.clean()
            itemsById.removeValue(forKey: idToRemove)
        }
    }

    private func makeCachedItem(
        for id: ID,
        at index: Data.Index,
        view: Attribute<ForEachType>,
        inputs: ViewListInputs
    ) -> Item {
        let viewSubgraph: Subgraph = .init()
        let viewOutputsSubgraph: Subgraph = .init()
        return viewSubgraph.withDependencyCapture {
            let childView: Attribute<Content> = makeChildView(for: id, view: view)
            let childViewListOutputs: ViewListOutputs = Content.makeViewList(
                childView,
                inputs: inputs
            )
            return .init(
                index: index,
                viewSubgraph: viewSubgraph,
                viewOutputsSubgraph: viewOutputsSubgraph,
                viewList: childViewListOutputs.viewList
            )
        }
    }

    private func makeChildView(
        for id: ID,
        view: Attribute<ForEachType>
    ) -> Attribute<Content> {
        Attribute("ForEach Child View \(id)") { [unowned self] in
            guard let item = self.itemsById[id] else {
                fatalError("Element with ID \(id) not found in itemsById")
            }
            let forEach: ForEach<Data, ID, Content> = view.wrappedValue
            let element: Data.Element = forEach.data[item.index]
            return forEach.makeChildView(element)
        }
    }
}

extension ForEachState {
    final class Item {
        let viewSubgraph: Subgraph
        let viewOutputsSubgraph: Subgraph
        let viewList: Attribute<any ViewList>
        var viewOutputs: [ViewOutputs]?

        var index: Data.Index {
            willSet {
                guard newValue != index else { return }
                viewOutputsSubgraph.clean()
                viewOutputs = nil
            }
        }

        init(
            index: Data.Index,
            viewSubgraph: Subgraph,
            viewOutputsSubgraph: Subgraph,
            viewList: Attribute<any ViewList>
        ) {
            self.index = index
            self.viewSubgraph = viewSubgraph
            self.viewOutputsSubgraph = viewOutputsSubgraph
            self.viewList = viewList
        }
    }
}

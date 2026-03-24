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
            let childValue: Content = forEach.makeChildView(element)

            if let existingItem = itemsById[id] {
                existingItem.update(index: index, childValue: childValue)
            } else {
                let item: Item = makeCachedItem(
                    for: id,
                    at: index,
                    childValue: childValue,
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
        childValue: Content,
        inputs: ViewListInputs
    ) -> Item {
        let viewSubgraph: Subgraph = .init()
        let viewOutputsSubgraph: Subgraph = .init()

        return viewSubgraph.withDependencyCapture {
            let childView: Attribute<Content> = Attribute("ForEach Child View \(id)") {
                childValue
            }

            let childViewListOutputs: ViewListOutputs = Content.makeViewList(
                childView,
                inputs: inputs
            )

            return .init(
                index: index,
                childView: childView,
                viewListOutputs: childViewListOutputs,
                viewSubgraph: viewSubgraph,
                viewOutputsSubgraph: viewOutputsSubgraph
            )
        }
    }
}

extension ForEachState {
    final class Item {
        let childView: Attribute<Content>

        let viewListOutputs: ViewListOutputs

        let viewSubgraph: Subgraph
        let viewOutputsSubgraph: Subgraph

        private(set) var index: Data.Index
        private(set) var viewOutputs: [ViewOutputs]?

        init(
            index: Data.Index,
            childView: Attribute<Content>,
            viewListOutputs: ViewListOutputs,
            viewSubgraph: Subgraph,
            viewOutputsSubgraph: Subgraph
        ) {
            self.index = index
            self.childView = childView
            self.viewListOutputs = viewListOutputs
            self.viewSubgraph = viewSubgraph
            self.viewOutputsSubgraph = viewOutputsSubgraph
        }

        func update(
            index newIndex: Data.Index,
            childValue: Content,
        ) {
            childView.wrappedValue = childValue

            if newIndex != index {
                index = newIndex
                viewOutputsSubgraph.clean()
                viewOutputs = nil
            }
        }

        func cacheViewOutputs(_ viewOutputs: [ViewOutputs]) {
            self.viewOutputs = viewOutputs
        }
    }
}

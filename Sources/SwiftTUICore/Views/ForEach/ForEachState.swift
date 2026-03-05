//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/03/2026.
//

import Foundation
import AttributeGraph

private enum Edit {
    case insertion(newOffset: Int)
    case removal(oldOffset: Int)
}

final class ForEachState<Data: RandomAccessCollection, ID: Hashable, Content: View> {
    private(set) var view: Attribute<ForEach<Data, ID, Content>>?

    private(set) var itemsById: [ID: Item] = [:]
    private(set) var orderedIds: [ID] = []

    func updateState(with view: Attribute<ForEach<Data, ID, Content>>) {
        self.view = view

        var diff: DiffContext = .init(
            oldItemsById: itemsById,
            oldOrdered: orderedIds
        )

        let unwrappedView: ForEach<Data, ID, Content> = view.wrappedValue
        var index: Data.Index = unwrappedView.data.startIndex

        while index != unwrappedView.data.endIndex {
            let element: Data.Element = unwrappedView.data[index]
            let id: ID = element[keyPath: unwrappedView.id]
            let newOffset: Int = diff.newOrdered.count

            if let existingItem = itemsById[id] {
                // Existing item, update the index
                existingItem.index = index
            } else {
                // New item, create and insert
                print("Calling makeItem for new item with ID \(id) at new offset \(newOffset)")
                itemsById[id] = makeItem(id: id, index: index, from: view)
                diff.editsById[id] = .insertion(newOffset: newOffset)
            }

            diff.appendNew(id)
            unwrappedView.data.formIndex(after: &index)
        }

        for removedId in diff.removedIDs() {
            let oldOffset: Int = diff.oldOffset(for: removedId)
            diff.editsById[removedId] = .removal(oldOffset: oldOffset)
            diff.pendingRemovals.append(removedId)
        }

        orderedIds = diff.newOrdered

        print("Ordered IDs: \(orderedIds)")
        print(diff.editsById)

//        CallbackQueue.shared.enqueue { [weak self] in
//            guard let self else { return }
//            for pendingRemoval in diff.pendingRemovals {
//                guard let item = self.itemsById[pendingRemoval] else { continue }
//                print("Removing item with ID \(pendingRemoval) at old offset \(item.index)")
//                item.subgraph.clean()
//            }
//        }
    }

    private func makeItem(
        id: ID,
        index: Data.Index,
        from view: Attribute<ForEach<Data, ID, Content>>
    ) -> Item {
        let subgraph: Subgraph = .init()
        return subgraph.withDependencyCapture {
            let element = view.wrappedValue.data[index]

            let childView: Attribute<Content> = Attribute {
                return view.wrappedValue.makeChildView(element)
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

        var viewOutputs: Attribute<ViewOutputs>?

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

extension ForEachState {
    private struct DiffContext {
        let oldItemsById: [ID: Item]
        let oldOrdered: [ID]
        let oldOffsets: [ID: Int]
        let oldIDs: Set<ID>

        var newOrdered: [ID] = []
        var newIDs: Set<ID> = []

        var editsById: [ID: Edit] = [:]

        var pendingRemovals: [ID] = []

        init(
            oldItemsById: [ID: Item],
            oldOrdered: [ID]
        ) {
            self.oldItemsById = oldItemsById
            self.oldOrdered = oldOrdered
            self.oldOffsets = Dictionary(uniqueKeysWithValues: oldOrdered.enumerated().map { ($1, $0) })
            self.oldIDs = Set(oldOrdered)
        }

        mutating func appendNew(_ id: ID) {
            newOrdered.append(id)
            newIDs.insert(id)
        }

        func removedIDs() -> Set<ID> {
            oldIDs.subtracting(newIDs)
        }

        func oldOffset(for id: ID) -> Int {
            oldOffsets[id] ?? -1
        }
    }
}


extension ForEachState: CustomStringConvertible {
    var description: String {
        "ForEachState with \(orderedIds.count) items"
    }
}

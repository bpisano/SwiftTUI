//
//  ForEachState.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import AttributeGraph
import Foundation

@MainActor
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
                existingItem.update(
                    index: index,
                    childValue: childValue
                )
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
            itemToRemove.clean()
            itemsById.removeValue(forKey: idToRemove)
        }
    }

    private func makeCachedItem(
        for id: ID,
        at index: Data.Index,
        childValue: Content,
        inputs: ViewListInputs
    ) -> Item {
        let subgraph: Subgraph = .init()
        return subgraph.withDependencyCapture {
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
                views: childViewListOutputs.views,
                subgraph: subgraph
            )
        }
    }

    func viewIds(forEachImplicitId: Int) -> [ViewId]? {
        var result: [ViewId] = []

        for elementId in orderedIds {
            guard let item = itemsById[elementId],
                  let childViewIds = item.viewIds(
                    forEachImplicitId: forEachImplicitId,
                    explicitId: .init(elementId)
                  ) else {
                return nil
            }
            result.append(contentsOf: childViewIds)
        }

        return result
    }
}

extension ForEachState {
    @MainActor
    final class Item {
        let childView: Attribute<Content>
        let views: ViewListOutputs.Views
        let subgraph: Subgraph

        private(set) var index: Data.Index
        private(set) var viewOutputs: [ViewOutputs]?

        init(
            index: Data.Index,
            childView: Attribute<Content>,
            views: ViewListOutputs.Views,
            subgraph: Subgraph
        ) {
            self.index = index
            self.childView = childView
            self.views = views
            self.subgraph = subgraph
        }

        func update(
            index: Data.Index,
            childValue: Content
        ) {
            self.index = index
            childView.wrappedValue = childValue
        }

        func viewIds(
            forEachImplicitId: Int,
            explicitId: AnyHashable
        ) -> [ViewId]? {
            let childViewIds: [ViewId]?

            switch views {
            case let .staticList(elements):
                childViewIds = elements.flatMap(\.retainedViewIds)
            case let .dynamicList(viewList):
                childViewIds = viewList.wrappedValue.viewIds
            }

            guard let childViewIds else { return nil }

            return childViewIds.map { childViewId in
                var explicit: [ViewId.Explicit] = [
                    .init(id: explicitId),
                    .init(id: ViewId.Scope(implicitId: childViewId.implicitId))
                ]
                explicit.append(contentsOf: childViewId.explicit)

                return .init(
                    implicitId: forEachImplicitId,
                    index: childViewId.index,
                    explicit: explicit
                )
            }
        }

        @MainActor
        func makeViewOutputs(
            startIndex: inout Int,
            inputs: ViewInputs,
            makeViewOutputs interceptor: @escaping ViewList.MakeViewOutputsInterceptor
        ) -> [ViewOutputs] {
            if let viewOutputs {
                startIndex += viewOutputs.count
                return viewOutputs
            }

            let outputs: [ViewOutputs] = subgraph.withDependencyCapture {
                ViewListOutputs(views: views, nextImplicitId: 0).makeViewOutputs(
                    startIndex: &startIndex,
                    inputs: inputs,
                    makeViewOutputs: interceptor
                )
            }
            viewOutputs = outputs
            return outputs
        }

        func clean() {
            viewOutputs = nil
            subgraph.clean()
        }
    }
}

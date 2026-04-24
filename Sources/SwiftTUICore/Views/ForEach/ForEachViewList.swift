//
//  ForEachViewList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

struct ForEachViewList<Data: RandomAccessCollection, ID: Hashable, Content: View>: ViewList {
    typealias ForEachType = ForEach<Data, ID, Content>
    typealias StateType = ForEachState<Data, ID, Content>

    private let view: Attribute<ForEachType>
    private let state: StateType
    private let implicitId: Int
    private let cachedViewIds: [ViewId]?

    init(
        view: Attribute<ForEachType>,
        state: StateType,
        implicitId: Int,
        viewIds: [ViewId]?
    ) {
        self.view = view
        self.state = state
        self.implicitId = implicitId
        self.cachedViewIds = viewIds
    }

    var viewIds: [ViewId]? { cachedViewIds }

    func applyItems(_ body: (RetainedViewListItem) -> Void) {
        for elementId in state.orderedIds {
            guard let item = state.itemsById[elementId] else { continue }

            let explicitId: AnyHashable = .init(elementId)
            guard let viewIds = item.viewIds(
                forEachImplicitId: implicitId,
                explicitId: explicitId
            ) else { continue }

            let retainedItem = RetainedViewListItem(
                identity: AnyHashable(ObjectIdentifier(item)),
                viewIds: viewIds
            ) { startIndex, inputs, outerMakeViewOutputs in
                let interceptor: MakeViewOutputsInterceptor = { index, childViewId, inputs, makeViewOutputs in
                    let composedViewId: ViewId = composeViewId(
                        explicitId: explicitId,
                        childViewId: childViewId
                    )
                    return outerMakeViewOutputs(
                        &index,
                        composedViewId,
                        inputs,
                        makeViewOutputs
                    )
                }

                return item.makeViewOutputs(
                    startIndex: &startIndex,
                    inputs: inputs,
                    makeViewOutputs: interceptor
                )
            }
            body(retainedItem)
        }
    }

    private func composeViewId(
        explicitId: AnyHashable,
        childViewId: ViewId
    ) -> ViewId {
        var explicit: [ViewId.Explicit] = [
            .init(id: explicitId),
            .init(id: ViewId.Scope(implicitId: childViewId.implicitId))
        ]
        explicit.append(contentsOf: childViewId.explicit)

        return .init(
            implicitId: implicitId,
            index: childViewId.index,
            explicit: explicit
        )
    }
}

extension ForEachViewList: @MainActor AttributeValueRepresentable {
    var attributeValueDescription: String {
        "ForEachViewList"
    }
}

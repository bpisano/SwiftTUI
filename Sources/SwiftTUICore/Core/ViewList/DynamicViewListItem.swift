//
//  DynamicViewListItem.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/04/2026.
//

import Foundation
import AttributeGraph

@MainActor
final class DynamicViewListItem<Content: View> {
    let childView: Attribute<Content>

    private let views: ViewListOutputs.Views
    private let subgraph: Subgraph
    private var viewOutputs: [ViewOutputs]?

    init(
        childView: Attribute<Content>,
        views: ViewListOutputs.Views,
        subgraph: Subgraph
    ) {
        self.childView = childView
        self.views = views
        self.subgraph = subgraph
    }

    static func make(
        childLabel: String,
        childValue: Content,
        inputs: ViewListInputs
    ) -> DynamicViewListItem<Content> {
        let subgraph = Subgraph()

        return subgraph.withDependencyCapture {
            let childView: Attribute<Content> = Attribute(childLabel) {
                childValue
            }

            let childViewListOutputs: ViewListOutputs = Content.makeViewList(
                childView,
                inputs: inputs
            )

            return .init(
                childView: childView,
                views: childViewListOutputs.views,
                subgraph: subgraph
            )
        }
    }

    func update(childValue: Content) {
        childView.wrappedValue = childValue
    }

    var viewIds: [ViewId]? {
        views.viewIds
    }

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

    @MainActor
    func retainedViewListItem() -> RetainedViewListItem? {
        guard let viewIds else { return nil }

        return RetainedViewListItem(identity: AnyHashable(ObjectIdentifier(self)), viewIds: viewIds) { startIndex, inputs, makeViewOutputs in
            self.makeViewOutputs(
                startIndex: &startIndex,
                inputs: inputs,
                makeViewOutputs: makeViewOutputs
            )
        }
    }

    func clean() {
        viewOutputs = nil
        subgraph.clean()
    }
}

struct DynamicItemViewList<Content: View>: ViewList {
    let item: DynamicViewListItem<Content>
    private let cachedViewIds: [ViewId]?

    @MainActor
    init(item: DynamicViewListItem<Content>) {
        self.item = item
        self.cachedViewIds = item.viewIds
    }

    var viewIds: [ViewId]? { cachedViewIds }

    func applyItems(_ body: (RetainedViewListItem) -> Void) {
        guard let item = item.retainedViewListItem() else { return }
        body(item)
    }
}

extension DynamicItemViewList: @MainActor AttributeValueRepresentable {
    var attributeValueDescription: String {
        "DynamicItemViewList"
    }
}

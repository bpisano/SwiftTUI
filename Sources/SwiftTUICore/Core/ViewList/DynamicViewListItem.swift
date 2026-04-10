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

struct DynamicItemViewList<Content: View>: ViewList {
    let item: DynamicViewListItem<Content>

    var viewIds: [ViewId]? { nil }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        item.makeViewOutputs(
            startIndex: &startIndex,
            inputs: inputs,
            makeViewOutputs: makeViewOutputs
        )
    }
}

extension DynamicItemViewList: @MainActor AttributeValueRepresentable {
    var attributeValueDescription: String {
        "DynamicItemViewList"
    }
}

//
//  ConditionalViewListRule.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 31/03/2026.
//

import Foundation
import AttributeGraph

@MainActor
final class ConditionalViewListRule<TrueContent: View, FalseContent: View>: @MainActor Rule {
    @Attribute private var view: ConditionalView<TrueContent, FalseContent>

    private let inputs: ViewListInputs
    private var cache: Cache?

    init(
        view: Attribute<ConditionalView<TrueContent, FalseContent>>,
        inputs: ViewListInputs
    ) {
        self._view = view
        self.inputs = inputs
    }

    func evaluate() -> any ViewList {
        switch view.storage {
        case let .trueContent(trueContent):
            makeTrueContentViewList(trueContent)
        case let .falseContent(falseContent):
            makeFalseContentViewList(falseContent)
        }
    }

    private func makeTrueContentViewList(_ trueContent: TrueContent) -> any ViewList {
        if case let .trueContent(cachedItem) = cache {
            cachedItem.update(childValue: trueContent)
            return DynamicItemViewList(item: cachedItem)
        }

        cleanCache()

        let item: DynamicViewListItem<TrueContent> = .make(
            childLabel: "Conditional True Child",
            childValue: trueContent,
            inputs: inputs
        )

        cache = .trueContent(item: item)

        return DynamicItemViewList(item: item)
    }

    private func makeFalseContentViewList(_ falseContent: FalseContent) -> any ViewList {
        if case let .falseContent(cachedItem) = cache {
            cachedItem.update(childValue: falseContent)
            return DynamicItemViewList(item: cachedItem)
        }

        cleanCache()

        let item: DynamicViewListItem<FalseContent> = .make(
            childLabel: "Conditional False Child",
            childValue: falseContent,
            inputs: inputs
        )

        cache = .falseContent(item: item)

        return DynamicItemViewList(item: item)
    }

    private func cleanCache() {
        switch cache {
        case let .trueContent(item):
            item.clean()
        case let .falseContent(item):
            item.clean()
        case nil:
            break
        }
    }
}

extension ConditionalViewListRule {
    enum Cache {
        case trueContent(item: DynamicViewListItem<TrueContent>)
        case falseContent(item: DynamicViewListItem<FalseContent>)
    }
}

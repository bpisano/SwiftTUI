//
//  OptionalViewListRule.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 09/04/2026.
//

import Foundation
import AttributeGraph

@MainActor
final class OptionalViewListRule<Content: View>: @MainActor Rule {
    @Attribute private var view: Content?

    private let inputs: ViewListInputs
    private var cache: Cache?

    init(
        view: Attribute<Content?>,
        inputs: ViewListInputs
    ) {
        self._view = view
        self.inputs = inputs
    }

    func evaluate() -> any ViewList {
        if let content = view {
            makeContentViewList(content)
        } else {
            makeEmptyViewList()
        }
    }

    private func makeContentViewList(_ content: Content) -> any ViewList {
        if case let .content(cachedItem) = cache {
            cachedItem.update(childValue: content)
            return DynamicItemViewList(item: cachedItem)
        }

        cleanCache()

        let item: DynamicViewListItem<Content> = .make(
            childLabel: "Optional Content Child",
            childValue: content,
            inputs: inputs
        )

        cache = .content(item: item)
        return DynamicItemViewList(item: item)
    }

    private func makeEmptyViewList() -> any ViewList {
        if case let .empty(cachedItem) = cache {
            return DynamicItemViewList(item: cachedItem)
        }

        cleanCache()

        let item: DynamicViewListItem<EmptyView> = .make(
            childLabel: "Optional Empty Child",
            childValue: .init(),
            inputs: inputs
        )

        cache = .empty(item: item)
        return DynamicItemViewList(item: item)
    }

    private func cleanCache() {
        switch cache {
        case let .content(item):
            item.clean()
        case let .empty(item):
            item.clean()
        case nil:
            break
        }
    }
}

extension OptionalViewListRule {
    enum Cache {
        case content(item: DynamicViewListItem<Content>)
        case empty(item: DynamicViewListItem<EmptyView>)
    }
}

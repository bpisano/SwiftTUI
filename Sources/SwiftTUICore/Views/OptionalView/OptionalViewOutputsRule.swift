//
//  OptionalViewOutputsRule.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 09/04/2026.
//

import Foundation
import AttributeGraph

@MainActor
final class OptionalViewOutputsRule<Content: View>: @MainActor Rule {
    @Attribute private var view: Content?

    private let inputs: ViewInputs
    private let subgraph: Subgraph = .init()

    private var cache: Cache?

    init(
        view: Attribute<Content?>,
        inputs: ViewInputs
    ) {
        self._view = view
        self.inputs = inputs
    }

    func evaluate() -> ViewOutputs {
        if let content = view {
            makeContentOutputs(content)
        } else {
            makeEmptyOutputs()
        }
    }

    private func makeContentOutputs(_ content: Content) -> ViewOutputs {
        if case let .content(cachedChild, cachedOutputs) = cache {
            cachedChild.wrappedValue = content
            return cachedOutputs
        }

        subgraph.clean()

        let (child, viewOutputs) = subgraph.withDependencyCapture {
            let child: Attribute<Content> = .init("Optional Content Child") { content }
            let outputs: ViewOutputs = Content.makeView(child, inputs: inputs)
            return (child, outputs)
        }

        cache = .content(child: child, outputs: viewOutputs)
        return viewOutputs
    }

    private func makeEmptyOutputs() -> ViewOutputs {
        if case let .empty(cachedOutputs) = cache {
            return cachedOutputs
        }

        subgraph.clean()

        let viewOutputs = subgraph.withDependencyCapture {
            let emptyView: Attribute<EmptyView> = .init("Optional Empty Child") { .init() }
            return EmptyView.makeView(emptyView, inputs: inputs)
        }

        cache = .empty(outputs: viewOutputs)
        return viewOutputs
    }
}

extension OptionalViewOutputsRule {
    enum Cache {
        case content(child: Attribute<Content>, outputs: ViewOutputs)
        case empty(outputs: ViewOutputs)
    }
}

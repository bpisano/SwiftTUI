//
//  ConditionalViewListRule.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 31/03/2026.
//

import Foundation
import AttributeGraph

final class ConditionalViewListRule<TrueContent: View, FalseContent: View>: Rule {
    @Attribute private var view: ConditionalView<TrueContent, FalseContent>

    private let inputs: ViewListInputs
    private let subgraph: Subgraph = .init()

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
        if case let .trueContent(cachedChild, cachedViewList) = cache {
            cachedChild.wrappedValue = trueContent
            return cachedViewList.wrappedValue
        }

        subgraph.clean()

        let (child, viewList) = subgraph.withDependencyCapture {
            let child: Attribute<TrueContent> = .init("Conditional True Child") { trueContent }
            let outputs: ViewListOutputs = TrueContent.makeViewList(child, inputs: inputs)
            let viewList: Attribute<any ViewList> = outputs.makeViewListAttribute("Conditional True ViewList")
            return (child, viewList)
        }

        cache = .trueContent(
            child: child,
            viewList: viewList
        )

        return viewList.wrappedValue
    }

    private func makeFalseContentViewList(_ falseContent: FalseContent) -> any ViewList {
        if case let .falseContent(cachedChild, cachedViewList) = cache {
            cachedChild.wrappedValue = falseContent
            return cachedViewList.wrappedValue
        }

        subgraph.clean()

        let (child, viewList) = subgraph.withDependencyCapture {
            let child: Attribute<FalseContent> = .init("Conditional False Child") { falseContent }
            let outputs: ViewListOutputs = FalseContent.makeViewList(child, inputs: inputs)
            let viewList: Attribute<any ViewList> = outputs.makeViewListAttribute("Conditional False ViewList")
            return (child, viewList)
        }

        cache = .falseContent(
            child: child,
            viewList: viewList
        )

        return viewList.wrappedValue
    }
}

extension ConditionalViewListRule {
    enum Cache {
        case trueContent(
            child: Attribute<TrueContent>,
            viewList: Attribute<any ViewList>
        )
        case falseContent(
            child: Attribute<FalseContent>,
            viewList: Attribute<any ViewList>
        )
    }
}

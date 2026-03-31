//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 31/03/2026.
//

import Foundation
import AttributeGraph

final class ConditionalViewOutputsRule<TrueContent: View, FalseContent: View>: Rule {
    @Attribute private var view: ConditionalView<TrueContent, FalseContent>

    private let inputs: ViewInputs
    private let subgraph: Subgraph = .init()

    private var cache: Cache?

    init(
        view: Attribute<ConditionalView<TrueContent, FalseContent>>,
        inputs: ViewInputs
    ) {
        self._view = view
        self.inputs = inputs
    }

    func evaluate() -> ViewOutputs {
        switch view.storage {
        case let .trueContent(trueContent):
            makeTrueContentOutputs(trueContent)
        case let .falseContent(falseContent):
            makeFalseContentOutputs(falseContent)
        }
    }

    private func makeTrueContentOutputs(_ trueContent: TrueContent) -> ViewOutputs {
        if case let .trueContent(cachedChild, cachedOutputs) = cache {
            cachedChild.wrappedValue = trueContent
            return cachedOutputs
        }

        subgraph.clean()

        let (child, viewOutputs) = subgraph.withDependencyCapture {
            let child: Attribute<TrueContent> = .init("Conditional True Child") { trueContent }
            let outputs: ViewOutputs = TrueContent.makeView(child, inputs: inputs)
            return (child, outputs)
        }

        cache = .trueContent(
            child: child,
            outputs: viewOutputs
        )

        return viewOutputs
    }


    private func makeFalseContentOutputs(_ falseContent: FalseContent) -> ViewOutputs {
        if case let .falseContent(cachedChild, cachedOutputs) = cache {
            cachedChild.wrappedValue = falseContent
            return cachedOutputs
        }
        
        subgraph.clean()
        
        let (child, viewOutputs) = subgraph.withDependencyCapture {
            let child: Attribute<FalseContent> = .init("Conditional False Child") { falseContent }
            let outputs: ViewOutputs = FalseContent.makeView(child, inputs: inputs)
            return (child, outputs)
        }
        
        cache = .falseContent(
            child: child,
            outputs: viewOutputs
        )
        
        return viewOutputs
    }
}

extension ConditionalViewOutputsRule {
    enum Cache {
        case trueContent(
            child: Attribute<TrueContent>,
            outputs: ViewOutputs
        )
        case falseContent(
            child: Attribute<FalseContent>,
            outputs: ViewOutputs
        )
    }
}

//
//  DynamicViewOutputsRule.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 06/06/2026.
//

import Foundation
import AttributeGraph

@MainActor
final class DynamicViewOutputsRule<Content: DynamicView>: Rule {
    typealias Value = ViewOutputs

    @Attribute private var view: Content

    private let inputs: ViewInputs
    private var info: Info?

    init(
        view: Attribute<Content>,
        inputs: ViewInputs
    ) {
        self._view = view
        self.inputs = inputs
    }

    func evaluate() -> ViewOutputs {
        let branchId: AnyHashable = view.dynamicBranchId

        if let info, info.branchId == branchId {
            return info.outputs
        }

        info?.subgraph.clean()

        let subgraph: Subgraph = .init()
        let outputs: ViewOutputs = subgraph.withDependencyCapture {
            Content.makeDynamicChildView($view, inputs: inputs)
        }

        info = .init(
            branchId: branchId,
            subgraph: subgraph,
            outputs: outputs
        )

        return outputs
    }
}

private extension DynamicViewOutputsRule {
    struct Info {
        let branchId: AnyHashable
        let subgraph: Subgraph
        let outputs: ViewOutputs
    }
}

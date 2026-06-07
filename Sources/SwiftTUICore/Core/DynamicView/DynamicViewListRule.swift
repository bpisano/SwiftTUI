//
//  DynamicViewListRule.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 06/06/2026.
//

import Foundation
import AttributeGraph

@MainActor
final class DynamicViewListRule<Content: DynamicView>: Rule {
    typealias Value = any ViewList

    @Attribute private var view: Content

    private let inputs: ViewListInputs
    private var info: Info?

    init(
        view: Attribute<Content>,
        inputs: ViewListInputs
    ) {
        self._view = view
        self.inputs = inputs
    }

    func evaluate() -> any ViewList {
        let branchId: AnyHashable = view.dynamicBranchId
        if let info, info.branchId == branchId {
            return DynamicBranchViewList(branchId: branchId, subgraph: info.subgraph, base: info.childList.wrappedValue)
        }

        info?.subgraph.clean()

        let subgraph: Subgraph = .init()
        let childList: Attribute<any ViewList> = subgraph.withDependencyCapture {
            let outputs: ViewListOutputs = Content.makeDynamicChildViewList($view, inputs: inputs)
            return outputs.makeViewListAttribute("DynamicView Child ViewList")
        }

        let info: Info = .init(
            branchId: branchId,
            subgraph: subgraph,
            childList: childList
        )
        self.info = info

        return DynamicBranchViewList(branchId: branchId, subgraph: subgraph, base: childList.wrappedValue)
    }
}

private extension DynamicViewListRule {
    struct Info {
        let branchId: AnyHashable
        let subgraph: Subgraph
        let childList: Attribute<any ViewList>
    }
}

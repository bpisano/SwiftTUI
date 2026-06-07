//
//  DynamicBranchViewList.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 06/06/2026.
//

import Foundation
import AttributeGraph

@MainActor
struct DynamicBranchViewList: ViewList {
    private let branchId: AnyHashable
    private let subgraph: Subgraph
    private let base: any ViewList
    private let cachedViewIds: [ViewId]?

    init(
        branchId: AnyHashable,
        subgraph: Subgraph,
        base: any ViewList
    ) {
        self.branchId = branchId
        self.subgraph = subgraph
        self.base = base
        self.cachedViewIds = base.viewIds?.map { $0.taggingBranch(branchId) }
    }

    var viewIds: [ViewId]? { cachedViewIds }

    func applyItems(_ body: (RetainedViewListItem) -> Void) {
        let branchId: AnyHashable = self.branchId
        let subgraph: Subgraph = self.subgraph
        base.applyItems { item in
            let taggedViewIds: [ViewId] = item.viewIds.map { $0.taggingBranch(branchId) }
            let taggedItem: RetainedViewListItem = .init(
                identity: AnyHashable(BranchScopedIdentity(branchId: branchId, base: item.identity)),
                viewIds: taggedViewIds
            ) { startIndex, inputs, makeViewOutputs in
                // Materialize the child's (lazily-deferred) outputs inside the branch's
                // subgraph so everything it creates — including `ForEach` item subgraphs
                // that would otherwise be orphaned when `graph.subgraph` is nil — is torn
                // down with the branch on the next transition.
                subgraph.withDependencyCapture {
                    item.makeViewOutputs(
                        startIndex: &startIndex,
                        inputs: inputs,
                        makeViewOutputs: makeViewOutputs
                    )
                }
            }
            body(taggedItem)
        }
    }
}

private extension DynamicBranchViewList {
    struct BranchScopedIdentity: Hashable {
        let branchId: AnyHashable
        let base: AnyHashable
    }
}

extension DynamicBranchViewList: @MainActor AttributeValueRepresentable {
    var attributeValueDescription: String {
        "DynamicBranchViewList"
    }
}

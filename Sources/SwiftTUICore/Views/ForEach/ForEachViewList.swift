//
//  ForEachViewList.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

struct ForEachViewList<Data: RandomAccessCollection, ID: Hashable, Content: View>: ViewList {
    typealias ForEachType = ForEach<Data, ID, Content>
    typealias StateType = ForEachState<Data, ID, Content>

    private let view: Attribute<ForEachType>
    private let state: StateType

    init(
        view: Attribute<ForEachType>,
        state: StateType
    ) {
        self.view = view
        self.state = state
    }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        var viewOutputs: [ViewOutputs] = []

        for elementId in state.orderedIds {
            guard let item = state.itemsById[elementId] else { continue }

            if let cachedViewOutputs = item.viewOutputs {
                viewOutputs.append(contentsOf: cachedViewOutputs)
                startIndex += cachedViewOutputs.count
                continue
            }

            item.viewOutputsSubgraph.withDependencyCapture {
                let outputs: [ViewOutputs] = item.viewListOutputs.makeViewOutputs(
                    startIndex: &startIndex,
                    inputs: inputs,
                    makeViewOutputs: makeViewOutputs
                )
                item.cacheViewOutputs(outputs)
                viewOutputs.append(contentsOf: outputs)
            }
        }
        return viewOutputs
    }
}

extension ForEachViewList: AttributeValueRepresentable {
    var attributeValueDescription: String {
        "ForEachViewList with \(state.orderedIds.count) items"
    }
}

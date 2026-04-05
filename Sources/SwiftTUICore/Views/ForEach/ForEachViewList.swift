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

    var viewIds: [ViewId]? { nil }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        var viewOutputs: [ViewOutputs] = []

        for elementId in state.orderedIds {
            guard let item = state.itemsById[elementId] else { continue }

            let outputs: [ViewOutputs] = item.makeViewOutputs(
                startIndex: &startIndex,
                inputs: inputs,
                makeViewOutputs: makeViewOutputs
            )
            viewOutputs.append(contentsOf: outputs)
        }
        return viewOutputs
    }
}

extension ForEachViewList: @MainActor AttributeValueRepresentable {
    var attributeValueDescription: String {
        "ForEachViewList"
    }
}

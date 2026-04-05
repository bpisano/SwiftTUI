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

    var viewIds: [ViewId]? { nil }

    private let view: Attribute<ForEachType>
    private let state: StateType
    private let implicitId: Int

    init(
        view: Attribute<ForEachType>,
        state: StateType,
        implicitId: Int
    ) {
        self.view = view
        self.state = state
        self.implicitId = implicitId
    }

    func makeViewOutputs(
        startIndex: inout Int,
        inputs: ViewInputs,
        makeViewOutputs outerMakeViewOutputs: @escaping MakeViewOutputsInterceptor
    ) -> [ViewOutputs] {
        var viewOutputs: [ViewOutputs] = []

        for elementId in state.orderedIds {
            guard let item = state.itemsById[elementId] else { continue }

            let forEachImplicitId: Int = implicitId
            let explicitId: AnyHashable = .init(elementId)

            let interceptor: MakeViewOutputsInterceptor = { index, childViewId, inputs, makeViewOutputs in
                let composedViewId: ViewId = .init(
                    implicitId: forEachImplicitId,
                    index: childViewId.implicitId,
                    explicit: [ViewId.Explicit(id: explicitId)]
                )
                return outerMakeViewOutputs(
                    &index,
                    composedViewId,
                    inputs,
                    makeViewOutputs
                )
            }

            let outputs: [ViewOutputs] = item.makeViewOutputs(
                startIndex: &startIndex,
                inputs: inputs,
                makeViewOutputs: interceptor
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

//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 04/03/2026.
//

import Foundation
import AttributeGraph

struct ForEachViewList<Data: RandomAccessCollection, ID: Hashable, Content: View>: ViewList {
    var count: Int {
        state.orderedIds.count
    }
    var viewIds: ViewId.Views? {
        let itemLists: [Attribute<ViewList>] = state.orderedIds.compactMap { id in
            state.itemsById[id]?.viewList
        }
        return MergedViewList(itemLists).viewIds
    }

    private let state: ForEachState<Data, ID, Content>

    init(state: ForEachState<Data, ID, Content>) {
        self.state = state
    }

    func makeViews(
        from start: inout Int,
        inputs: ViewInputs,
        body: (inout Int, ViewInputs, @escaping MakeElement) -> (ViewOutputs?, Bool)
    ) {
        print("ForEachViewList", state.orderedIds)
        for id in state.orderedIds {
            guard let item = state.itemsById[id] else { continue }
            print(item.index)
            if let outputs = item.viewOutputs {
                print("Using cached outputs for item with ID \(id) at index \(item.index)")
                let result = body(&start, inputs) { _ in
                    outputs.wrappedValue
                }
                if !result.1 {
                    break
                }
            } else {
                item.subgraph.withDependencyCapture {
//                    item.viewList.wrappedValue.makeViews(
//                        from: &start,
//                        inputs: inputs,
//                        body: body
//                    )
                    item.viewList.wrappedValue.makeViews(from: &start, inputs: inputs) { _, inputs, makeElements in
                        let viewOutputs = makeElements(inputs)
                        item.viewOutputs = Attribute(wrappedValue: viewOutputs)
                        return (viewOutputs, true)
                    }
                }
            }
        }
    }
}

extension ForEachViewList: CustomStringConvertible {
    var description: String {
        "ForEachViewList with \(state.orderedIds.count) items"
    }
}

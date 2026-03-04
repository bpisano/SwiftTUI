//
//  ForEachViewListRule.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 04/03/2026.
//

import Foundation
import AttributeGraph

struct ForEachViewListRule<Data: RandomAccessCollection, ID: Hashable, Content: View>: @MainActor StatefulRule {
    typealias Value = ViewList

    private let state: ForEachState<Data, ID, Content>

    @Attribute private var view: ForEach<Data, ID, Content>

    init(
        state: ForEachState<Data, ID, Content>,
        view: Attribute<ForEach<Data, ID, Content>>
    ) {
        self.state = state
        self._view = view
    }

    func update() -> ViewList {
        print("Updating ForEachViewListRule")
        state.updateState(with: $view)
        return ForEachViewList(state: state)
    }
}

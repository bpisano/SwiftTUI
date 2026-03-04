//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 22/02/2026.
//

import Foundation
import AttributeGraph

struct ForEach<Data: RandomAccessCollection, ID: Hashable, Content: View>: View, PrimitiveView {
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let makeChildView: (Data.Element) -> Content

    init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder _ content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.makeChildView = content
    }
}

extension ForEach where Data.Element: Identifiable, ID == Data.Element.ID {
    init(
        _ data: Data,
        @ViewBuilder _ content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = \.id
        self.makeChildView = content
    }
}

extension ForEach {
    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let state: ForEachState<Data, ID, Content> = .init()

        let viewList = Attribute(
            rule: ForEachViewListRule(
                state: state,
                view: view
            )
        )
        viewList.label = "ForEach ViewList"

        return .dynamicList(
            viewList,
            inputs: inputs
        )
    }

    static func viewListCount(inputs: ViewListCountInputs) -> Int? {
        nil
    }
}

extension ForEach: CustomStringConvertible {
    var description: String {
        "ForEach with \(data.count) items"
    }
}

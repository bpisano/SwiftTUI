//
//  ForEach.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
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
        makeChildView: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.makeChildView = makeChildView
    }
}

extension ForEach {
    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        fatalError("Not implemented")
    }

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        let state = ForEachState<Data, ID, Content>()

        let viewList: Attribute<any ViewList> = Attribute("ForEach ViewList") {
            state.update(with: view, inputs: inputs)
            return ForEachViewList(view: view, state: state)
        }

        return .init(viewList: viewList)
    }
}

extension ForEach: AttributeValueRepresentable {
    var attributeValueDescription: String {
        "ForEach with \(data.count) elements"
    }
}

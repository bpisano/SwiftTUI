//
//  ForEach.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import AttributeGraph

public struct ForEach<Data: RandomAccessCollection, ID: Hashable, Content: View>: View, PrimitiveView {
    let data: Data
    let id: KeyPath<Data.Element, ID>
    let makeChildView: (Data.Element) -> Content

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder _ makeChildView: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self.id = id
        self.makeChildView = makeChildView
    }
}

extension ForEach where Data.Element: Identifiable, ID == Data.Element.ID {
    public init(
        _ data: Data,
        @ViewBuilder _ makeChildView: @escaping (Data.Element) -> Content
    ) {
        self.init(
            data,
            id: \.id,
            makeChildView
        )
    }
}

extension ForEach {
    public static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        fatalError("Not implemented")
    }

    public static func makeViewList(
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
    public var attributeValueDescription: String {
        "ForEach with \(data.count) elements"
    }
}

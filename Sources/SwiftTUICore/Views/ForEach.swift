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
        let view: Self = view.wrappedValue
        var childOutputs: [ViewListOutputs?] = Array(
            repeating: nil,
            count: view.data.count
        )

        for (index, element) in view.data.enumerated() {
            let childView: Content = view.makeChildView(element)
            @Attribute var idView: IDView<Content, ID> = IDView(
                childView,
                id: element[keyPath: view.id]
            )

            let childViewOutputs: ViewListOutputs = type(of: idView).makeViewList(
                $idView,
                inputs: inputs
            )
            childOutputs[index] = childViewOutputs
        }

        return .concat(
            childOutputs.compactMap { $0 },
            inputs: inputs
        )
    }
}

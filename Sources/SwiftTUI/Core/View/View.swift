//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import AttributeGraph

protocol View {
    static func makeView(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputs
    static func makeViewList(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputsList
    static func viewListCount(_ view: Attribute<Self>) -> Int?
}

protocol PrimitiveView: View {}

protocol UnaryView: View {}

extension UnaryView {
    static func makeViewList(_ view: Attribute<Self>, inputs: ViewInputs) -> ViewOutputsList {
        let output = makeView(view, inputs: inputs)
        return .init(
            layoutComputers: [output.layoutComputer],
            displayList: output.displayList
        )
    }

    static func viewListCount(_ view: Attribute<Self>) -> Int? {
        1
    }
}

protocol MultiView: View {}

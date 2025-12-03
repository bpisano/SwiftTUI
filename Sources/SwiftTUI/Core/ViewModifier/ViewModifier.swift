//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 02/12/2025.
//

import AttributeGraph
import Foundation

protocol ViewModifier {
    static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        body: @escaping (ViewInputs) -> ViewOutputs
    ) -> ViewOutputs

    static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        body: @escaping (ViewListInputs) -> ViewListOutputs
    ) -> ViewListOutputs

    static func viewListCount(
        inputs: ViewListCountInputs,
        body: (ViewListCountInputs) -> Int?
    ) -> Int?
}

extension View {
    func modifier<M: ViewModifier>(_ modifier: M) -> ModifiedContent<Self, M> {
        ModifiedContent(self, modifier: modifier)
    }
}

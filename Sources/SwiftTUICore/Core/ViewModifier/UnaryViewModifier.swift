//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/12/2025.
//

import AttributeGraph
import Foundation

protocol UnaryViewModifier: ViewModifier {}

extension UnaryViewModifier {
    static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        body: @escaping (ViewListInputs) -> ViewListOutputs
    ) -> ViewListOutputs {
        .unaryViewList(viewType: Self.self, inputs: inputs) { viewInputs in
            Self.makeView(modifier, inputs: viewInputs) { modifiedInputs in
                let contentListOutputs = body(.init())
                let contentList = contentListOutputs.makeViewList()

                var contentOutput: ViewOutputs!
                var index = 0
                contentList.makeViews(from: &index, inputs: modifiedInputs) {
                    index, inputs, makeView in
                    let viewOutputs: ViewOutputs = makeView(inputs)
                    contentOutput = viewOutputs
                    return (viewOutputs, true)
                }
                return contentOutput
            }
        }
    }

    static func viewListCount(
        inputs: ViewListCountInputs,
        body: (ViewListCountInputs) -> Int?
    ) -> Int? {
        1
    }
}

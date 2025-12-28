//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 27/12/2025.
//

import Foundation
import AttributeGraph

protocol UnaryViewModifier: ViewModifier { }

extension UnaryViewModifier {
    static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        body: @escaping (ViewListInputs) -> ViewListOutputs
    ) -> ViewListOutputs {
        .unaryViewList(viewType: Self.self, inputs: inputs) { viewInputs in
            // Call the modifier's makeView, which will handle the body
            Self.makeView(modifier, inputs: viewInputs) { modifiedInputs in
                // Get the content's view list and make a single view from it
                let contentListOutputs = body(.init())
                let contentList = contentListOutputs.makeViewList()

                // Make the first (and only) view from the content
                var contentOutput: ViewOutputs!
                contentList.makeViews(from: 0, inputs: modifiedInputs) { output in
                    contentOutput = output
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

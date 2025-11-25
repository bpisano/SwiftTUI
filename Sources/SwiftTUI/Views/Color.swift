//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 20/11/2025.
//

import Foundation
import AttributeGraph

//struct Color: UnaryView {
//    private let name: String
//
//    init(_ name: String) {
//        self.name = name
//    }
//}
//
//extension Color {
//    static func makeView(_ view: Attribute<Color>, inputs: ViewInputs) -> ViewOutputs {
//        @Attribute var layoutComputer = LayoutComputer { proposedSize in
//            proposedSize.replacingUnspecifiedDimensions()
//        } place: { rect, proposal in
//
//        }
//
//        @Attribute var displayList = DisplayList(
//            commands: [
//                .init(
//                    .putChar(view.wrappedValue.name.first ?? "C"),
//                    in: inputs.frame.wrappedValue
//                )
//            ]
//        )
//
//        $layoutComputer.label = "Color Layout Computer"
//        $displayList.label = "Color Display List"
//
//        return ViewOutputs(
//            layoutComputer: $layoutComputer,
//            displayList: $displayList
//        )
//    }
//}

//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 16/03/2026.
//

import Foundation
import AttributeGraph
import Geometry

struct LayoutView<L: Layout, Content: View>: View, PrimitiveView {
    private let layout: L
    private let content: Content

    init(
        layout: L,
        content: Content
    ) {
        self.layout = layout
        self.content = content
    }
}

extension LayoutView {
    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        var childGeometries: Attribute<[ViewGeometry]>!

        let childOutputs = Attribute("\(Content.self) Child Outputs") {
            let contentAttribute: Attribute<Content> = view.map(\.content)
            let viewListInputs: ViewListInputs = .init(viewInputs: inputs)
            let contentViewListOutputs: ViewListOutputs = Content.makeViewList(
                contentAttribute,
                inputs: viewListInputs
            )
            let contentViewList: any ViewList = contentViewListOutputs.viewList.wrappedValue

            var index: Int = 0

            return contentViewList.makeViewOutputs(
                startIndex: &index,
                inputs: inputs
            ) { index, inputs, makeViewOutputs in
                let currentIndex: Int = index
                let modifiedInputs = ViewInputs(
                    position: Attribute {
                        childGeometries.wrappedValue[currentIndex].origin
                    },
                    size: Attribute {
                        childGeometries.wrappedValue[currentIndex].size
                    },
                    phase: inputs.phase,
                    storage: inputs.storage
                )
                return makeViewOutputs(modifiedInputs)
            }
        }

        let layoutComputer = Attribute("\(Content.self) LayoutComputer") {
            let layout: L = view.wrappedValue.layout
            let childLayoutComputers: [LayoutComputer] = childOutputs.wrappedValue
                .map(\.layoutComputer.wrappedValue)
            return layout.layoutComputer(for: childLayoutComputers)
        }

        let displayList = Attribute("\(Content.self) DisplayList") {
            DisplayList(
                childOutputs.wrappedValue
                    .map { .childList($0.displayList.wrappedValue) }
            )
        }

        childGeometries = Attribute("\(Content.self) Child Geometries") {
            let proposal: ProposedViewSize = .init(inputs.size.wrappedValue)
            let containerSize: Size = layoutComputer.wrappedValue.sizeThatFits(proposal)
            return layoutComputer.wrappedValue.viewGeometries(
                Rect(
                    origin: inputs.position.wrappedValue,
                    size: containerSize
                )
            )
        }

        return .init(
            layoutComputer: layoutComputer,
            displayList: displayList
        )
    }

    static func makeViewList(
        _ view: Attribute<Self>,
        inputs: ViewListInputs
    ) -> ViewListOutputs {
        .unaryViewListOutputs("\(Content.self) ViewList") { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }
}

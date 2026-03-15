//
//  VStack.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry
import AttributeGraph

struct VStack<Content: View>: View, PrimitiveView {
    private let content: Content

    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
}

extension VStack {
    static func makeView(
        _ view: Attribute<Self>,
        inputs: ViewInputs
    ) -> ViewOutputs {
        let content: Attribute<Content> = view.map(\.content)
        content.label = "\(Content.self)"

        let childViewListOutputs: ViewListOutputs = Content.makeViewList(
            content,
            inputs: .init(viewInputs: inputs)
        )

        var childGeometries: Attribute<[Rect]>!

        let childViewOutputs = Attribute("VStack Child ViewOutputs") {
            var index: Int = 0
            let childViewList: any ViewList = childViewListOutputs.viewList.wrappedValue
            return childViewList.makeViewOutputs(startIndex: &index, inputs: inputs) { index, inputs, makeViewOutputs in
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

        let layoutComputer = Attribute("VStack LayoutComputer") {
            VStackLayout().layoutComputer(
                for: childViewOutputs.wrappedValue.map(\.layoutComputer.wrappedValue)
            )
        }

        let displayList = Attribute("VStack DisplayList") {
            DisplayList(
                childViewOutputs
                    .wrappedValue
                    .map(\.displayList.wrappedValue)
                    .map { .childList($0) }
            )
        }

        childGeometries = Attribute("VStack Child Geometries") {
            let proposal = ProposedViewSize(inputs.size.wrappedValue)
            let containerSize = layoutComputer.wrappedValue.sizeThatFits(proposal)
            return layoutComputer.wrappedValue.viewGeometries(
                Rect(
                    origin: .zero,
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
        let offset = MemoryLayout<VStack<Content>>.offset(of: \.content) ?? 0
        let content: Attribute<Content> = view.unsafeOffset(at: offset, as: Content.self)
        return Content.makeViewList(content, inputs: inputs)
    }
}

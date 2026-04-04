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
        var engine: LayoutEngine<L>?

        let contentAttribute: Attribute<Content> = view.map(\.content)
        let viewListInputs: ViewListInputs = .init(viewInputs: inputs)
        let contentViewListOutputs: ViewListOutputs = Content.makeViewList(
            contentAttribute,
            inputs: viewListInputs
        )
        let contentViewOutputs: Attribute<[ViewOutputs]> = contentViewListOutputs.makeViewOutputsAttribute(
            "\(Content.self) Child Outputs",
            inputs: inputs
        ) { index, inputs, makeViewOutputs in
            let currentIndex: Int = index
            let modifiedInputs = ViewInputs(
                position: Attribute {
                    let childGeometries: [ViewGeometry] = childGeometries.wrappedValue
                    guard currentIndex < childGeometries.count else {
                        return .zero
                    }
                    return childGeometries[currentIndex].origin
                },
                size: Attribute {
                    let childGeometries: [ViewGeometry] = childGeometries.wrappedValue
                    guard currentIndex < childGeometries.count else {
                        return .zero
                    }
                    return childGeometries[currentIndex].size
                },
                phase: inputs.phase,
                storage: inputs.storage
            )
            return makeViewOutputs(modifiedInputs)
        }

        let layoutComputer = Attribute("\(Content.self) LayoutComputer") {
            let layout: L = view.wrappedValue.layout
            let childAttributes: [Attribute<LayoutComputer>] = contentViewOutputs.wrappedValue
                .map(\.layoutComputer)

            if let existing = engine {
                existing.update(layout: layout, subviewAttributes: childAttributes)
            } else {
                engine = LayoutEngine(layout: layout, subviewAttributes: childAttributes)
            }

            return engine!.makeLayoutComputer()
        }

        let displayList = Attribute("\(Content.self) DisplayList") {
            DisplayList(
                contentViewOutputs.wrappedValue
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

extension LayoutView: @MainActor AttributeValueRepresentable {
    var attributeValueDescription: String {
        "LayoutView"
    }
}

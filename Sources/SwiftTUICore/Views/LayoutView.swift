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
        var containerInfo: Attribute<[ViewId: Int]>!
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
        ) { index, viewId, inputs, makeViewOutputs in
            let stableId: ViewId = viewId
            let modifiedInputs = ViewInputs(
                position: Attribute {
                    guard let index = containerInfo.wrappedValue[stableId] else { return .zero }
                    let childGeometries: [ViewGeometry] = childGeometries.wrappedValue
                    guard index < childGeometries.count else { return .zero }
                    return childGeometries[index].origin
                },
                size: Attribute {
                    guard let index = containerInfo.wrappedValue[stableId] else { return .zero }
                    let childGeometries: [ViewGeometry] = childGeometries.wrappedValue
                    guard index < childGeometries.count else { return .zero }
                    return childGeometries[index].size
                },
                phase: inputs.phase,
                storage: inputs.storage
            )
            let rawOutputs = makeViewOutputs(modifiedInputs)
            // Re-wrap with the stable id so ContainerInfo can find it in the flat array.
            return ViewOutputs(viewId: stableId, layoutComputer: rawOutputs.layoutComputer, displayList: rawOutputs.displayList)
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

        containerInfo = Attribute("\(Content.self) ContainerInfo") {
            var map: [ViewId: Int] = [:]
            for (i, output) in contentViewOutputs.wrappedValue.enumerated() {
                map[output.viewId] = i
            }
            return map
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
        .unaryViewListOutputs("\(Content.self) ViewList", implicitId: inputs.implicitId) { inputs in
            Self.makeView(view, inputs: inputs)
        }
    }
}

extension LayoutView: @MainActor AttributeValueRepresentable {
    var attributeValueDescription: String {
        "LayoutView"
    }
}

//
//  FrameViewModifier.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Geometry
import AttributeGraph

struct FrameViewModifier: ViewModifier, PrimitiveViewModifier {
    private let width: GeometryUnit?
    private let height: GeometryUnit?

    init(
        width: GeometryUnit?,
        height: GeometryUnit?
    ) {
        self.width = width
        self.height = height
    }
}

extension FrameViewModifier {
    static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        var childViewOutputs: [ViewOutputs] = []

        let layoutComputer = Attribute("Frame LayoutComputer") {
            let modifier: FrameViewModifier = modifier.wrappedValue
            let layout: FrameLayout = .init(
                width: modifier.width,
                height: modifier.height
            )
            return layout.layoutComputer(for: childViewOutputs.map(\.layoutComputer.wrappedValue))
        }

        let modifiedPosition = Attribute {
            let inputFrame: Rect = .init(
                origin: inputs.position.wrappedValue,
                size: inputs.size.wrappedValue
            )
            let layoutGeometries: [ViewGeometry] = layoutComputer.wrappedValue.viewGeometries(
                inputFrame)
            let layoutGeometry: ViewGeometry = layoutGeometries[0]
            return layoutGeometry.origin
        }

        let modifiedSize = Attribute {
            let inputFrame: Rect = .init(
                origin: inputs.position.wrappedValue,
                size: inputs.size.wrappedValue
            )
            let layoutGeometries: [ViewGeometry] = layoutComputer.wrappedValue.viewGeometries(
                inputFrame)
            let layoutGeometry: ViewGeometry = layoutGeometries[0]

            var layoutGeometrySize: Size = layoutGeometry.size
            layoutGeometrySize.width = layoutGeometrySize.width.clamped(0, inputFrame.size.width)
            layoutGeometrySize.height = layoutGeometrySize.height.clamped(0, inputFrame.size.height)

            return layoutGeometrySize
        }

        let modifiedInputs: ViewInputs = .init(
            position: modifiedPosition,
            size: modifiedSize,
            phase: inputs.phase,
            storage: inputs.storage
        )

        childViewOutputs = [makeViewOutputs(modifiedInputs)]

        return .init(
            layoutComputer: layoutComputer,
            displayList: childViewOutputs[0].displayList
        )
    }

    static func makeViewList(
        _ modifier: Attribute<Self>,
        inputs: ViewListInputs,
        makeViewListOutputs: @escaping MakeViewListOutputs
    ) -> ViewListOutputs {
        .unaryViewListOutputs("Frame Modifier ViewList") { inputs in
            Self.makeView(modifier, inputs: inputs) { modifiedInputs in
                let modifiedViewListInputs: ViewListInputs = .init(viewInputs: modifiedInputs)
                let childViewListOutputs: ViewListOutputs = makeViewListOutputs(modifiedViewListInputs)
                let childViewList: any ViewList = childViewListOutputs.viewList.wrappedValue
                let viewOutputs: [ViewOutputs] = childViewList.makeViewOutputs(inputs: modifiedInputs)
                return viewOutputs[0]
            }
        }
    }
}

extension View {
    public func frame(
        width: GeometryUnit? = nil,
        height: GeometryUnit? = nil
    ) -> some View {
        modifier(
            FrameViewModifier(
                width: width,
                height: height
            )
        )
    }
}

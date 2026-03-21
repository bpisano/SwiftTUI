//
//  FrameViewModifier.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import AttributeGraph
import Foundation
import Geometry

struct FrameViewModifier: ViewModifier, PrimitiveViewModifier, UnaryViewModifier {
    private let width: GeometryUnit?
    private let height: GeometryUnit?
    private let alignment: Alignment

    init(
        width: GeometryUnit?,
        height: GeometryUnit?,
        alignment: Alignment
    ) {
        self.width = width
        self.height = height
        self.alignment = alignment
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
                height: modifier.height,
                alignment: modifier.alignment
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
}

extension View {
    public func frame(
        width: GeometryUnit? = nil,
        height: GeometryUnit? = nil,
        alignment: Alignment = .center
    ) -> some View {
        modifier(
            FrameViewModifier(
                width: width,
                height: height,
                alignment: alignment
            )
        )
    }
}

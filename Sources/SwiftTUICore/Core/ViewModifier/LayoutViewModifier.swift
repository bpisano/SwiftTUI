//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 28/03/2026.
//

import Foundation
import AttributeGraph
import Geometry

protocol LayoutViewModifier: ViewModifier {
    static func makeLayout(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
    ) -> any Layout
}

extension LayoutViewModifier {
    static func makeView(
        _ modifier: Attribute<Self>,
        inputs: ViewInputs,
        makeViewOutputs: @escaping MakeViewOutputs
    ) -> ViewOutputs {
        var childViewOutputs: [ViewOutputs] = []

        let layoutComputer = Attribute("\(Self.self) LayoutComputer") {
            let layout: any Layout = makeLayout(modifier, inputs: inputs)
            return layout.layoutComputer(for: childViewOutputs.map(\.layoutComputer.wrappedValue))
        }

        let modifiedPosition = Attribute {
            let inputFrame: Rect = .init(
                origin: inputs.position.wrappedValue,
                size: inputs.size.wrappedValue
            )
            let layoutComputer: LayoutComputer = layoutComputer.wrappedValue
            let layoutGeometries: [ViewGeometry] = layoutComputer.viewGeometries(inputFrame)
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
            environment: inputs.environment,
            storage: inputs.storage
        )

        childViewOutputs = [makeViewOutputs(modifiedInputs)]

        return .init(
            layoutComputer: layoutComputer,
            displayList: childViewOutputs[0].displayList,
            focusList: childViewOutputs[0].focusList
        )
    }
}

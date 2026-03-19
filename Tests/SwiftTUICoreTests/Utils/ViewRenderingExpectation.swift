//
//  UnitTestRenderer.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 16/03/2026.
//

import AttributeGraph
import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

func expectView<V: View>(
    in size: Size,
    @ViewBuilder _ makeView: () -> V,
    toRender expected: () -> String,
) {
    let view: V = makeView()

    @Attribute var screenOrigin: Point = .zero
    @Attribute var screenSize: Size = size
    @Attribute var viewPhase: ViewPhase = .active
    @Attribute var viewAttribute: V = view

    let inputs: ViewInputs = .init(
        position: $screenOrigin,
        size: $screenSize,
        phase: $viewPhase,
        storage: .init()
    )
    let outputs: ViewOutputs = V.makeView($viewAttribute, inputs: inputs)

    let configuration: RenderingConfiguration = .init(
        emptyChar: ".",
        lineJoinSeparator: "\n",
        includeColors: false
    )
    let renderer: TerminalRenderer = .init(configuration: configuration)
    let frame: String = renderer.renderFrame(
        displayList: outputs.displayList.wrappedValue,
        in: size
    )

    #expect(frame == expected())
}

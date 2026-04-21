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

@MainActor
func expectView<V: View>(
    in size: Size,
    @ViewBuilder _ makeView: () -> V,
    toRender expected: () -> String,
) async {
    let view: V = makeView()

    @Attribute var screenOrigin: Point = .zero
    @Attribute var screenSize: Size = size
    @Attribute var viewPhase: ViewPhase = .active
    @Attribute var viewAttribute: V = view

    let inputs: ViewInputs = .init(
        position: $screenOrigin,
        size: $screenSize,
        phase: $viewPhase,
        environment: .init(wrappedValue: .init()),
        storage: .init()
    )
    let outputs: ViewOutputs = V.makeView($viewAttribute, inputs: inputs)

    await expectDisplayList(outputs.displayList, in: size, toRender: expected)
}

@MainActor
func expectDisplayList(
    _ displayList: Attribute<DisplayList>,
    in size: Size,
    toRender expected: () -> String
) async {
    let configuration: RenderingConfiguration = .init(
        emptyChar: ".",
        lineJoinSeparator: "\n",
        renderColor: false
    )
    let renderer: TerminalRenderer = .init(configuration: configuration)
    let frame: String = await renderer.renderFrame(
        displayList: displayList.wrappedValue,
        in: size
    )

    #expect(frame == expected())
}

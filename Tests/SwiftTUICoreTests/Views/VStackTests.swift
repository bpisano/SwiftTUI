//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 15/03/2026.
//

import Foundation
import Testing
import Geometry
@testable import AttributeGraph
@testable import SwiftTUICore

@Suite("VStack")
struct VStackTests {
    @Test
    func `One Element`() async throws {
        // TODO: Implement test
    }
}

@Test
func `VStack`() {
    @Attribute("Screen position") var position: Point = .zero
    @Attribute("Screen size") var size = Size(width: 20, height: 20)
    @Attribute("View phase") var phase: ViewPhase = .active
    let inputs = ViewInputs(
        position: $position,
        size: $size,
        phase: $phase,
        storage: .init()
    )

    @Attribute var view = VStack {
        Text("Alice")
        Text("Bob")
    }
    $view.label = "\(type(of: view))"

    let outputs = type(of: view).makeView($view, inputs: inputs)
    _ = outputs.displayList.wrappedValue

    copyToClipboard(Graph.current.digraph)
}

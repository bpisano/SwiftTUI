//
//  File.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 10/03/2026.
//

import Foundation
import Testing
import Geometry
import AttributeGraph
import SwiftTUICore
import AppKit

@Test
func `ViewModifier`() {
    @Attribute("Screen position") var position: Point = .zero
    @Attribute("Screen size") var size = Size(width: 2, height: 20)
    @Attribute("View phase") var phase: ViewPhase = .inactive
    let inputs = ViewInputs(
        position: $position,
        size: $size,
        phase: $phase,
        storage: .init()
    )
    @Attribute var view = Text("Hello world")
        .modifier(CustomViewModifier())
    $view.label = "\(type(of: view))"

    let outputs = type(of: view).makeView($view, inputs: inputs)

    _ = outputs.displayList.wrappedValue

    copyToClipboard(Graph.current.digraph)
}

struct CustomViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(width: 2)
    }
}

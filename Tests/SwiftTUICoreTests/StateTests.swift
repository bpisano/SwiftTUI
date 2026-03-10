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

@Test
func `@State`() {
    @Attribute("Screen position") var position: Point = .zero
    @Attribute("Screen size") var size = Size(width: 20, height: 20)
    @Attribute("View phase") var phase: ViewPhase = .inactive
    let inputs = ViewInputs(
        position: $position,
        size: $size,
        phase: $phase,
        storage: .init()
    )
    @Attribute var view = MyView()
    $view.label = "\(type(of: view))"

    let outputs = type(of: view).makeView($view, inputs: inputs)

    _ = outputs.displayList.wrappedValue

    view.count += 1

    _ = outputs.displayList.wrappedValue

    copyToClipboard(Graph.current.digraph)
}

private struct MyView: View {
    @State var count: Int = 0

    var body: some View {
        Text("\(count)")
    }
}

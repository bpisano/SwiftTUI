//
//  DebugTests.swift
//  DebugTests - Temporary debugging test target
//
//  This file replicates the playground code from Test.swift for debugging with breakpoints
//

import AttributeGraph
import Foundation
import Geometry
@testable import SwiftTUI
import Testing
import AppKit

@Test
func debugPlaygroundCode() {
    let graph = Graph()
    graph.makeCurrent()

    @Attribute var screenSize = Size(width: 5, height: 5)
    @Attribute var screenRect = Rect(origin: .zero, size: screenSize)
    let inputs = ViewInputs(frame: $screenRect)

//    @Attribute var count: Int = 0
//    @Attribute var count = 0
    @Attribute var view = VStack {
        Text("AAAAAA")
        Text("B")
    }
    let outputs = type(of: view).makeView($view, inputs: inputs)

    $screenSize.label = "Screen Size"
    $screenRect.label = "Screen Rect"
//    $count.label = "@State count"
    $view.label = "\(type(of: view))"

    let _ = outputs.displayList.wrappedValue

    print(graph)  // Initial state

    copyToClipboard(graph.description)
}

private func copyToClipboard(_ string: String) {
    let pasteboard: NSPasteboard = .general
    pasteboard.clearContents()
    pasteboard.setString(string, forType: .string)
}

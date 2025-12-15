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
    //    @Attribute var view = TupleView(
    //        Text("Hello \(count)"),
    //        Text("Test")
    //    )
    @Attribute var view = Color("X")
        .frame(width: 1, alignment: .leading)
        .frame(width: 3, alignment: .leading)
    let outputs = type(of: view).makeView($view, inputs: inputs)

    $screenSize.label = "Screen Size"
    $screenRect.label = "Screen Rect"
//    $count.label = "@State count"
    $view.label = "\(type(of: view))"

    let _ = outputs.displayList.wrappedValue

    print(graph)  // Initial state

    copyToClipboard(graph.description)
    //    count = 1
    //
    //    print(graph) // After state change
    //
    //    let _ = outputs.displayList.wrappedValue
    //
    //    print(graph) // After re-evaluation
}

func copyToClipboard(_ string: String) {
    let pasteboard: NSPasteboard = .general
    pasteboard.clearContents()
    pasteboard.setString(string, forType: .string)
}

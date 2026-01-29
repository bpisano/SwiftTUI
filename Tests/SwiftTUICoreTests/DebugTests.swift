//
//  DebugTests.swift
//  DebugTests - Temporary debugging test target
//
//  This file replicates the playground code from Test.swift for debugging with breakpoints
//

import Foundation
import Geometry
@testable import AttributeGraph
@testable import SwiftTUICore
import Testing
import AppKit

struct MyView: View {
    var body: some View {
        RootView {
            Text("a")
        }
    }
}

@Test
func debugPlaygroundCode() {
    let graph = Graph()
    graph.makeCurrent()

    @Attribute var screenPosition = Point.zero
    @Attribute var screenSize = Size(width: 10, height: 10)
    let inputs = ViewInputs(
        position: $screenPosition,
        size: $screenSize
    )

    @Attribute var view = RootView {
        VStack {
            Text("A")
        }
    }
//    @Attribute var view = MyView()
    let outputs = type(of: view).makeView($view, inputs: inputs)

    $screenPosition.label = "Screen Origin"
    $screenSize.label = "Screen Size"
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

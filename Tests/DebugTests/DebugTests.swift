//
//  DebugTests.swift
//  DebugTests - Temporary debugging test target
//
//  This file replicates the playground code from Test.swift for debugging with breakpoints
//

@testable import AttributeGraph
import Foundation
import Geometry
@testable import SwiftTUI
import Testing
import AppKit

struct MyView: View {
    var body: some View {
        VStack {
            Text("Hello")
            Color("B")
        }
    }
}

@Test
func debugPlaygroundCode() {
    let graph = Graph()
    graph.makeCurrent()

    @Attribute var screenPosition = Point.zero
    @Attribute var screenSize = Size(width: 5, height: 5)
    let inputs = ViewInputs(
        position: $screenPosition,
        size: $screenSize
    )

//    @Attribute var view = VStack {
//        Text("A")
//        Color("B")
//    }
    @Attribute var view = MyView()
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

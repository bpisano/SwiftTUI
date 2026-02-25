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

private struct User: Identifiable {
    let id: UUID = .init()
    let name: String
}

struct MyView: View {
    @State private var count: Int = 0

    var body: some View {
        Text("\(count)")
    }
}

struct MyViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                print("OK")
            }
    }
}

@Test
func debugPlaygroundCode() {
    let graph = Graph()
    graph.makeCurrent()

    @Attribute var screenPosition = Point.zero
    @Attribute var screenSize = Size(width: 10, height: 10)
    @Attribute var viewPhase = ViewPhase.inactive
    let inputs = ViewInputs(
        position: $screenPosition,
        size: $screenSize,
        phase: $viewPhase
    )

    let users: [User] = [User(name: "Alice"), User(name: "Bob"), User(name: "Charlie")]
    @Attribute var view = VStack {
        ForEach(users) { user in
            Text(user.name)
        }
    }

//    @Attribute var view = Text("Hello World")
    let outputs = type(of: view).makeView($view, inputs: inputs)

    $screenPosition.label = "Screen Origin"
    $screenSize.label = "Screen Size"
    $viewPhase.label = "View Phase"
    $view.label = "\(type(of: view))"

    let _ = outputs.displayList.wrappedValue
    copyToClipboard(graph.description)

    viewPhase = .active

    let _ = outputs.displayList.wrappedValue
    CallbackQueue.shared.executeAll()

    copyToClipboard(graph.description)
}

private func copyToClipboard(_ string: String) {
    let pasteboard: NSPasteboard = .general
    pasteboard.clearContents()
    pasteboard.setString(string, forType: .string)
}

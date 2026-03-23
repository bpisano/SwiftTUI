//
//  DebugTests.swift
//  DebugTests - Temporary debugging test target
//
//  This file replicates the playground code from Test.swift for debugging with breakpoints
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

struct _User: Identifiable {
    let id: Int
    let name: String
}

struct MyView: View {
    @State var isOn: Bool = false

    var body: some View {
        Text("Is On: \(isOn ? "Yes" : "No")")
            .onAppear {
                Task {
                    try await Task.sleep(for: .seconds(1))
                    isOn.toggle()
                }
            }
    }
}

@Test
func debugPlaygroundCode() {
    @Attribute var screenPosition: Point = .zero
    @Attribute var screenSize: Size = .init(width: 100, height: 100)
    @Attribute var viewPhase: ViewPhase = .active
    let inputs = ViewInputs(
        position: $screenPosition,
        size: $screenSize,
        phase: $viewPhase,
        storage: .init()
    )

    @Attribute var view = RootLayout {
        MyView()
    }

    let outputs = type(of: view).makeView($view, inputs: inputs)

    $screenPosition.label = "Screen Origin"
    $screenSize.label = "Screen Size"
    $viewPhase.label = "View Phase"
    $view.label = "\(type(of: view))"

    let _ = outputs.displayList.wrappedValue
    CallbackQueue.shared.executeAll()

    copyToClipboard(Graph.current.digraph)
}

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
    @State var users: [_User] = [
        .init(id: 1, name: "Alice")
    ]

    var body: some View {
        VStack {
            ForEach(users) { user in
                Text(user.name)
                    .padding()
            }
        }
    }
}

@Test @MainActor
func debugPlaygroundCode() {
    @Attribute var screenPosition: Point = .zero
    @Attribute var screenSize: Size = .init(width: 100, height: 100)
    @Attribute var viewPhase: ViewPhase = .active
    @Attribute var environment: EnvironmentValues = .init()
    let inputs = ViewInputs(
        position: $screenPosition,
        size: $screenSize,
        phase: $viewPhase,
        environment: $environment,
        storage: .init()
    )

    @Attribute var view = MyView()

    let outputs = type(of: view).makeView($view, inputs: inputs)

    $screenPosition.label = "Screen Origin"
    $screenSize.label = "Screen Size"
    $viewPhase.label = "View Phase"
    $environment.label = "Environment Values"
    $view.label = "\(type(of: view))"

    let _ = outputs.displayList.wrappedValue
    CallbackQueue.shared.executeAll()

    view.users = [
        .init(id: 1, name: "Alice"),
        .init(id: 2, name: "Bob")
    ]

    let _ = outputs.displayList.wrappedValue
    CallbackQueue.shared.executeAll()

    copyToClipboard(Graph.current.digraph)
}

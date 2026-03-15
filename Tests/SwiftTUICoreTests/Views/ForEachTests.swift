//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 03/03/2026.
//

import Foundation
import Testing
import Geometry
@testable import AttributeGraph
@testable import SwiftTUICore

@Test
func `ForEach`() {
    @Attribute("Screen position") var position: Point = .zero
    @Attribute("Screen size") var size = Size(width: 20, height: 20)
    @Attribute("View phase") var phase: ViewPhase = .active
    let inputs = ViewInputs(
        position: $position,
        size: $size,
        phase: $phase,
        storage: .init()
    )

    @Attribute var users = [
        User(id: 1, name: "Alice"),
        User(id: 2, name: "Bob"),
        User(id: 3, name: "Charlie")
    ]
    @Attribute var view = VStack(
        ForEach(users, id: \.id) { user in
            Text(user.name)
        }
    )
    $view.label = "\(type(of: view))"

    let outputs = type(of: view).makeView($view, inputs: inputs)

    _ = outputs.displayList.wrappedValue

    users = [
        User(id: 1, name: "Alice"),
        User(id: 2, name: "Bob"),
    ]

    _ = outputs.displayList.wrappedValue

    copyToClipboard(Graph.current.digraph)
}

private struct User: Identifiable {
    let id: Int
    let name: String
}

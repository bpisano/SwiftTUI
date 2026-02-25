//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 23/02/2026.
//

import Foundation
import Geometry
@testable import AttributeGraph
@testable import SwiftTUICore
import Testing

@Test
func `IDView`() {
    let graph = Graph()
    graph.makeCurrent()

    @Attribute var viewId: String = "1"
    @Attribute var view = Text("Hello")
        .id(viewId)

    var viewList = getViewList(of: $view)
    print(viewList.viewIds?[0].explicit?.id)

    viewId = "2"

    viewList = getViewList(of: $view)
    print(viewList.viewIds?[0].explicit?.id)
}

@Test
func `ForEach`() {
    let graph = Graph()
    graph.makeCurrent()

    @Attribute var users: [User] = [
        User(id: 1, name: "Alice"),
        User(id: 2, name: "Bob"),
        User(id: 3, name: "Charlie")
    ]
    @Attribute var view = ForEach(users) { user in
        Text(user.name)
    }

    var viewList = getViewList(of: $view)
    print(viewList.viewIds?.map(\.explicit?.id))


    users.append(User(id: 4, name: "David"))
    viewList = getViewList(of: $view)
    print(viewList.viewIds?.map(\.explicit?.id))
}

@Test
func `Mixed`() {
    let graph = Graph()
    graph.makeCurrent()

    @Attribute var users: [User] = [
        User(id: 1, name: "Alice"),
        User(id: 2, name: "Bob"),
        User(id: 3, name: "Charlie")
    ]
    @Attribute var view = VStack {
        Text("Hello")
            .id("1")
        Text("World")
            .id("2")
    }

    var viewList = getViewList(of: $view)
    print(viewList.viewIds?.count)
    print(viewList.viewIds?[0].explicit?.id)
    print(viewList.viewIds?[1].explicit?.id)

}

private func getViewList<V: View>(of view: Attribute<V>) -> ViewList {
    let outputs = V.makeViewList(
        view,
        inputs: .init()
    )
    return outputs.makeViewList()
}

private struct User: Identifiable {
    let id: Int
    let name: String
}

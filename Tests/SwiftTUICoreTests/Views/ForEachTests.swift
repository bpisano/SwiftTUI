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

//@Suite("ForEach")
//struct ForEachTests {
//    @Test
//    func `Ids should match elements`() throws {
//        let graph = Graph()
//        graph.makeCurrent()
//
//        let users: [User] = [
//            User(id: 1, name: "Alice"),
//            User(id: 2, name: "Bob"),
//            User(id: 3, name: "Charlie")
//        ]
//        @Attribute var view = ForEach(users) { user in
//            Text(user.name)
//        }
//
//        try expectExplicitIDStacks(getViewList(of: $view), equals: [[1], [2], [3]])
//    }
//
//    @Test
//    func `Ids should match elements order`() throws {
//        let graph = Graph()
//        graph.makeCurrent()
//
//        let users: [User] = [
//            User(id: 3, name: "Charlie"),
//            User(id: 1, name: "Alice"),
//            User(id: 2, name: "Bob")
//        ]
//        @Attribute var view = ForEach(users) { user in
//            Text(user.name)
//        }
//
//        try expectExplicitIDStacks(getViewList(of: $view), equals: [[3], [1], [2]])
//    }
//
//    @Test
//    func `Ids should be conserved in container`() throws {
//        let graph = Graph()
//        graph.makeCurrent()
//
//        let users: [User] = [
//            User(id: 1, name: "Alice"),
//            User(id: 2, name: "Bob"),
//            User(id: 3, name: "Charlie")
//        ]
//        @Attribute var view = VStack {
//            ForEach(users) { user in
//                Text(user.name)
//            }
//        }
//
//        try expectExplicitIDStacks(getViewList(of: $view), equals: [[1], [2], [3]])
//    }
//
//    @Test
//    func `Ids should update when elements are reordered`() throws {
//        let graph = Graph()
//        graph.makeCurrent()
//
//        @Attribute var users: [User] = [
//            User(id: 1, name: "Alice"),
//            User(id: 2, name: "Bob"),
//            User(id: 3, name: "Charlie")
//        ]
//        @Attribute var view = ForEach(users) { user in
//            Text(user.name)
//        }
//
//        try expectExplicitIDStacks(getViewList(of: $view), equals: [[1], [2], [3]])
//
//        users = [
//            User(id: 3, name: "Charlie"),
//            User(id: 2, name: "Bob"),
//            User(id: 1, name: "Alice")
//        ]
//        view = ForEach(users) { user in
//            Text(user.name)
//        }
//
//        try expectExplicitIDStacks(getViewList(of: $view), equals: [[3], [2], [1]])
//    }
//
//    @Test
//    func `Ids should update on insert and remove`() throws {
//        let graph = Graph()
//        graph.makeCurrent()
//
//        @Attribute var users: [User] = [
//            User(id: 1, name: "Alice"),
//            User(id: 2, name: "Bob"),
//            User(id: 3, name: "Charlie")
//        ]
//        @Attribute var view = ForEach(users) { user in
//            Text(user.name)
//        }
//
//        try expectExplicitIDStacks(getViewList(of: $view), equals: [[1], [2], [3]])
//
//        users.append(User(id: 4, name: "Dora"))
//        view = ForEach(users) { user in
//            Text(user.name)
//        }
//        try expectExplicitIDStacks(getViewList(of: $view), equals: [[1], [2], [3], [4]])
//
//        users = [users[0], users[2], users[3]]
//        view = ForEach(users) { user in
//            Text(user.name)
//        }
//        try expectExplicitIDStacks(getViewList(of: $view), equals: [[1], [3], [4]])
//    }
//
//    @Test
//    func `Duplicate ids should be reflected in view ids`() throws {
//        let graph = Graph()
//        graph.makeCurrent()
//
//        let users: [User] = [
//            User(id: 1, name: "Alice"),
//            User(id: 1, name: "Alice Copy"),
//            User(id: 2, name: "Bob")
//        ]
//        @Attribute var view = ForEach(users) { user in
//            Text(user.name)
//        }
//
//        try expectExplicitIDStacks(getViewList(of: $view), equals: [[1], [1], [2]])
//    }
//
//    @Test
//    func `Implicit ids should differ between foreach elements`() throws {
//        let graph = Graph()
//        graph.makeCurrent()
//
//        let users: [User] = [
//            User(id: 10, name: "A"),
//            User(id: 20, name: "B"),
//            User(id: 30, name: "C")
//        ]
//        @Attribute var view = ForEach(users) { user in
//            Text(user.name)
//        }
//
//        let viewIds = try #require(getViewList(of: $view).viewIds)
//        #expect(viewIds.count == 3)
//
//        let implicitIDs = (0..<viewIds.count).map { viewIds[$0].implicitId }
//        #expect(Set(implicitIDs).count == viewIds.count)
//    }
//
//    @Test
//    func `ForEach ids should include parent explicit id`() throws {
//        let graph = Graph()
//        graph.makeCurrent()
//
//        let users: [User] = [
//            User(id: 1, name: "Alice"),
//            User(id: 2, name: "Bob"),
//            User(id: 3, name: "Charlie")
//        ]
//        @Attribute var view = VStack {
//            ForEach(users) { user in
//                Text(user.name)
//            }
//        }
//        .id("container")
//
//        try expectExplicitIDStacks(
//            getViewList(of: $view),
//            equals: [[1, "container"], [2, "container"], [3, "container"]]
//        )
//    }
//}
//
//private func getViewList<V: View>(of view: Attribute<V>) -> ViewList {
//    let outputs = V.makeViewList(
//        view,
//        inputs: .init()
//    )
//    return outputs.makeViewList().wrappedValue
//}
//
//private func expectExplicitIDStacks(
//    _ viewList: ViewList,
//    equals expected: [[AnyHashable]]
//) throws {
//    let viewIds = try #require(viewList.viewIds)
//    #expect(viewIds.count == expected.count)
//
//    for index in 0..<expected.count {
//        let actual = viewIds[index].explicit.map(\.id)
//        #expect(actual == expected[index])
//    }
//}
//
//private struct User: Identifiable {
//    let id: Int
//    let name: String
//}

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

@Suite("ViewId")
struct ViewIdTests {
    @Test
    func `Single explicit id should be present`() throws {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var view = Text("Hello")
            .id("1")

        let viewIds = try #require(getViewList(of: $view).viewIds)
        #expect(viewIds.count == 1)
        #expect(viewIds[0].explicit.map(\.id) == [AnyHashable("1")])
    }

    @Test
    func `Nested id should stack explicit ids`() throws {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var view = Text("Hello")
            .id("child")
            .id("parent")

        let viewIds = try #require(getViewList(of: $view).viewIds)
        #expect(viewIds.count == 1)
        #expect(viewIds[0].explicit.map(\.id) == [AnyHashable("child"), AnyHashable("parent")])
    }

    @Test
    func `Sibling ids in container should stay independent`() throws {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var view = VStack {
            Text("Hello")
                .id("1")
            Text("World")
                .id("2")
        }

        let viewIds = try #require(getViewList(of: $view).viewIds)
        #expect(viewIds.count == 2)
        #expect(viewIds[0].explicit.map(\.id) == [AnyHashable("1")])
        #expect(viewIds[1].explicit.map(\.id) == [AnyHashable("2")])
    }
}

private func getViewList<V: View>(of view: Attribute<V>) -> ViewList {
    let outputs = V.makeViewList(
        view,
        inputs: .init()
    )
    return outputs.makeViewListAttribute().wrappedValue
}

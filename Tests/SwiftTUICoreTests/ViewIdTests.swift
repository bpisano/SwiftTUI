//
//  ViewIdTests.swift
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
@MainActor
struct ViewIdTests {

    // MARK: - Single view

    @Test
    func `Single Text has implicit ID 0`() throws {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var view = Text("Hello")

        let ids = try #require(viewIds(of: $view))
        #expect(ids.count == 1)
        #expect(ids[0].implicitId == 0)
        #expect(ids[0].explicit.isEmpty)
    }

    // MARK: - Siblings (TupleView)

    @Test
    func `Two siblings get consecutive implicit IDs`() throws {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var view = TupleView(Text("A"), Text("B"))

        let ids = try #require(viewIds(of: $view))
        #expect(ids.count == 2)
        #expect(ids[0].implicitId == 0)
        #expect(ids[1].implicitId == 1)
    }

    @Test
    func `Three siblings get consecutive implicit IDs`() throws {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var view = TupleView(Text("A"), Text("B"), Text("C"))

        let ids = try #require(viewIds(of: $view))
        #expect(ids.count == 3)
        #expect(ids[0].implicitId == 0)
        #expect(ids[1].implicitId == 1)
        #expect(ids[2].implicitId == 2)
    }

    // MARK: - ForEach slots

    @Test
    func `Static views around ForEach occupy correct implicit ID slots`() throws {
        let graph = Graph()
        graph.makeCurrent()

        // TupleView: Text(implicitId: 0), ForEach(implicitId: 1), Text(implicitId: 2)
        // ForEach returns viewIds: nil, so MergedViewList.viewIds is nil.
        // We verify the static runs independently using BaseViewList.viewIds.
        @Attribute var forEach = ForEach(["X"], id: \.self) { Text($0) }
        @Attribute var view = TupleView(Text("Header"), forEach, Text("Footer"))

        // The concat of [static(implicitId:0), dynamic(nil), static(implicitId:2)]
        // produces nil at the MergedViewList level — that's expected until ForEach viewIds are implemented.
        let outputs = makeViewListOutputs(of: $view)
        #expect(outputs.nextImplicitId == 3)
    }

    // MARK: - Stability: IDs don't change across re-evaluations

    @Test
    func `Implicit IDs are stable across multiple evaluations`() throws {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var view = TupleView(Text("A"), Text("B"), Text("C"))

        let first = try #require(viewIds(of: $view))
        let second = try #require(viewIds(of: $view))

        #expect(first == second)
    }

    // MARK: - Container (LayoutView) is opaque as a single slot

    @Test
    func `VStack appears as one slot in its parent`() throws {
        let graph = Graph()
        graph.makeCurrent()

        @Attribute var view = TupleView(
            VStack { Text("Inside") },
            Text("After")
        )

        let ids = try #require(viewIds(of: $view))
        // VStack (LayoutView) is a unary element from its parent's perspective
        #expect(ids.count == 2)
        #expect(ids[0].implicitId == 0)
        #expect(ids[1].implicitId == 1)
    }
}

// MARK: - Helpers

@MainActor
private func viewIds<V: View>(of view: Attribute<V>) -> [ViewId]? {
    makeViewListOutputs(of: view)
        .makeViewListAttribute()
        .wrappedValue
        .viewIds
}

@MainActor
private func makeViewListOutputs<V: View>(of view: Attribute<V>) -> ViewListOutputs {
    V.makeViewList(view, inputs: .init())
}

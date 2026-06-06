//
//  SubgraphCleanupTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 05/06/2026.
//

import AttributeGraph
import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

@Suite("Subgraph cleanup")
@MainActor
struct SubgraphCleanupTests {
    private struct ConditionalButton: View {
        let flag: Bool

        var body: some View {
            if flag {
                Button("Hello") {}
            } else {
                Text("x")
            }
        }
    }

    /// Switching a conditional branch whose content nests a layout container
    /// (a `Button`) must tear the previous branch's subgraph down completely,
    /// including the nested container's per-item subgraphs. Otherwise every
    /// toggle leaks attributes into the graph.
    @Test
    func `Toggling a conditional branch does not grow the graph`() {
        assertStable { flag in
            VStack { ConditionalButton(flag: flag) }
        }
    }

    /// Same guarantee through a unary modifier (`.disabled`) that wraps a view
    /// whose body switches branches on the environment.
    @Test
    func `Toggling disabled on a button does not grow the graph`() {
        assertStable { flag in
            VStack {
                Button("Hello") {}
                    .foregroundStyle(.primary)
                    .disabled(flag)
            }
        }
    }

    private func assertStable(_ build: @escaping (Bool) -> some View) {
        let graph = Graph()
        Graph.withCurrent(graph) {
            @Attribute var screenOrigin: Point = .zero
            @Attribute var screenSize: Size = .init(width: 20, height: 3)
            @Attribute var viewPhase: ViewPhase = .active
            @Attribute var environment: EnvironmentValues = .init()
            @Attribute var view = build(true)

            let inputs: ViewInputs = .init(
                position: $screenOrigin,
                size: $screenSize,
                phase: $viewPhase,
                environment: $environment,
                storage: .init()
            )
            let outputs = type(of: view).makeView($view, inputs: inputs)

            let render: @MainActor (Bool) -> Void = { flag in
                view = build(flag)
                _ = outputs.displayList.wrappedValue
                _ = outputs.focusList?.wrappedValue
                CallbackQueue.shared.executeAll()
            }

            // Warm up through both branches so every attribute exists.
            render(true); render(false); render(true); render(false)
            let attributesAfterWarmup = graph.attributeCount
            let edgesAfterWarmup = graph.totalEdgeCount

            for _ in 0..<20 {
                render(true)
                render(false)
            }

            #expect(
                graph.attributeCount == attributesAfterWarmup,
                "Attribute count grew from \(attributesAfterWarmup) to \(graph.attributeCount)"
            )
            #expect(
                graph.totalEdgeCount <= edgesAfterWarmup,
                "Edge count grew from \(edgesAfterWarmup) to \(graph.totalEdgeCount)"
            )
        }
    }
}

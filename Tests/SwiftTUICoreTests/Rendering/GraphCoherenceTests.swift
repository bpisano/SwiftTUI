//
//  GraphCoherenceTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 06/06/2026.
//

import AttributeGraph
import Foundation
import Geometry
import Testing

@testable import SwiftTUI
@testable import SwiftTUICore

/// Structural coherence of the attribute graph across dynamic transitions: no leak (counts
/// stable), no dangling edges (every edge endpoint stays registered) and no half-edges
/// (every edge referenced symmetrically). Exercises `ForEach` nested inside conditional
/// branches and `.id()` — the constructs that create and tear down subgraphs.
@Suite("Graph coherence")
@MainActor
struct GraphCoherenceTests {
    private struct Screen: View {
        let screen: Int
        let items: [String]

        var body: some View {
            switch screen {
            case 0:
                VStack(alignment: .leading) {
                    Text("Categories")
                    ForEach(items, id: \.self) { name in
                        Button(name) {}
                    }
                }
            case 1:
                VStack(alignment: .leading) {
                    Text("Difficulties")
                    ForEach(items, id: \.self) { name in
                        Button(name) {}
                            .foregroundStyle(.primary)
                            .disabled(false)
                    }
                }
            default:
                VStack(alignment: .leading) {
                    Text("Question")
                    ForEach(items, id: \.self) { name in
                        Text(name)
                    }
                }
                .id(items.count)
            }
        }
    }

    @Test
    func `ForEach inside dynamic transitions keeps the graph coherent`() {
        let graph: Graph = .init()
        Graph.withCurrent(graph) {
            @Attribute var screenOrigin: Point = .zero
            @Attribute var screenSize: Size = .init(width: 40, height: 16)
            @Attribute var viewPhase: ViewPhase = .active
            @Attribute var environment: EnvironmentValues = .init()
            @Attribute var view = RootLayout { Screen(screen: 0, items: ["a", "b", "c"]) }

            let inputs: ViewInputs = .init(
                position: $screenOrigin,
                size: $screenSize,
                phase: $viewPhase,
                environment: $environment,
                storage: .init()
            )
            let outputs = type(of: view).makeView($view, inputs: inputs)

            let datasets: [[String]] = [
                ["a", "b", "c"],
                ["x", "y"],
                ["one", "two", "three", "four"],
            ]

            let render: @MainActor (Int, [String]) -> Void = { screen, items in
                view = RootLayout { Screen(screen: screen, items: items) }
                _ = outputs.displayList.wrappedValue
                _ = outputs.focusList?.wrappedValue
                CallbackQueue.shared.executeAll()
            }

            let assertCoherent: @MainActor (String) -> Void = { context in
                let dangling = graph.danglingEdges
                let asymmetric = graph.asymmetricEdges
                #expect(dangling.isEmpty, "\(context): dangling edges \(dangling)")
                #expect(asymmetric.isEmpty, "\(context): asymmetric edges \(asymmetric)")
            }

            // Warm up across all branches and datasets so every attribute has existed.
            for screen in 0..<3 {
                for items in datasets {
                    render(screen, items)
                }
            }
            assertCoherent("after warmup")
            let attributesAfterWarmup: Int = graph.attributeCount
            let edgesAfterWarmup: Int = graph.totalEdgeCount

            for iteration in 0..<15 {
                for screen in 0..<3 {
                    let items: [String] = datasets[(iteration + screen) % datasets.count]
                    render(screen, items)
                    assertCoherent("screen \(screen), iteration \(iteration)")
                }
            }

            // Return to the warmup state so counts are comparable.
            render(2, datasets[2])
            assertCoherent("final")
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

    // MARK: - Regression probes (each isolates one construct that must not leak)

    private struct BareForEach: View {
        let items: [String]
        var body: some View {
            VStack(alignment: .leading) {
                ForEach(items, id: \.self) { name in
                    Button(name) {}
                }
            }
        }
    }

    private struct ThreeForEach: View {
        let which: Int
        let items: [String]
        var body: some View {
            switch which {
            case 0: VStack { Text("zero"); ForEach(items, id: \.self) { Text($0) } }
            case 1: VStack { Text("one"); ForEach(items, id: \.self) { Text($0) } }
            default: VStack { Text("two"); ForEach(items, id: \.self) { Text($0) } }
            }
        }
    }

    @Test
    func `Bare ForEach with varying data does not leak`() {
        let datasets: [[String]] = [["a", "b", "c"], ["x", "y"], ["p", "q", "r", "s"]]
        let (base, after) = stableCount({ BareForEach(items: datasets[$0]) }, steps: [0, 1, 2])
        #expect(after == base, "bare ForEach grew \(base) -> \(after)")
    }

    @Test
    func `Three-case switch with varying ForEach does not leak`() {
        let datasets: [[String]] = [["a", "b", "c"], ["x", "y"], ["p", "q", "r", "s"]]
        let (base, after) = stableCount({ ThreeForEach(which: $0, items: datasets[$0]) }, steps: [0, 1, 2])
        #expect(after == base, "three-case ForEach grew \(base) -> \(after)")
    }

    @Test
    func `Changing id around a varying ForEach does not leak`() {
        // A transition (`.id`) that tears down a `ForEach` whose data also changes must not
        // orphan the old branch's item subgraphs. Regression for the cleaned-attribute
        // re-evaluation leak.
        let datasets: [[String]] = [["a", "b", "c"], ["x", "y"], ["p", "q", "r", "s"]]
        let (base, after) = stableCount({ step in
            VStack { ForEach(datasets[step], id: \.self) { Text($0) } }.id(datasets[step].count)
        }, steps: [0, 1, 2])
        #expect(after == base, "id + ForEach grew \(base) -> \(after)")
    }

    private func stableCount(_ build: @escaping (Int) -> some View, steps: [Int]) -> (Int, Int) {
        let graph: Graph = .init()
        var result: (Int, Int) = (0, 0)
        Graph.withCurrent(graph) {
            @Attribute var screenOrigin: Point = .zero
            @Attribute var screenSize: Size = .init(width: 40, height: 16)
            @Attribute var viewPhase: ViewPhase = .active
            @Attribute var environment: EnvironmentValues = .init()
            @Attribute var view = RootLayout { build(steps[0]) }
            let inputs: ViewInputs = .init(
                position: $screenOrigin, size: $screenSize, phase: $viewPhase,
                environment: $environment, storage: .init()
            )
            let outputs = type(of: view).makeView($view, inputs: inputs)
            let render: @MainActor (Int) -> Void = { step in
                view = RootLayout { build(step) }
                _ = outputs.displayList.wrappedValue
                _ = outputs.focusList?.wrappedValue
                CallbackQueue.shared.executeAll()
            }
            for step in steps { render(step) }
            for step in steps { render(step) }
            let base: Int = graph.attributeCount
            for _ in 0..<10 { for step in steps { render(step) } }
            result = (base, graph.attributeCount)
        }
        return result
    }
}

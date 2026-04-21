//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 17/02/2026.
//

import Foundation
import Testing

@testable import AttributeGraph

@MainActor
@Suite("Subgraph")
struct SubgraphTests {

    @Test
    func `Attribute storage is freed after subgraph clean`() {
        final class Tracker {}
        weak var weakTracker: Tracker?

        let graph = Graph()
        graph.makeCurrent()
        let subgraph = Subgraph()

        do {
            let tracker = Tracker()
            weakTracker = tracker
            subgraph.withDependencyCapture {
                // The autoclosure captures `tracker` strongly inside the rule.
                @Attribute var value: Int = ObjectIdentifier(tracker).hashValue
            }
        }
        // Our strong ref is gone, but AttributeRef still holds the rule's closure.
        #expect(weakTracker != nil, "tracker should be alive while still in the graph")

        subgraph.clean()
        // After clean: AttributeRef freed → AnyRule freed → closure freed → tracker freed.
        #expect(weakTracker == nil, "tracker should be freed after subgraph.clean()")
    }
}

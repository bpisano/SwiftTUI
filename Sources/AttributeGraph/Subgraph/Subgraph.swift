//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 17/02/2026.
//

import Foundation

public final class Subgraph {
    private let graph: Graph
    private var attributeRefs: Set<AttributeRef> = []

    public var attributeLabels: [String] {
        attributeRefs.map(\.attribute.label)
    }

    public init(graph: Graph = .current) {
        self.graph = graph
    }

    public func withDependencyCapture<T>(_ body: () -> T) -> T {
        let previousSubgraph: Subgraph? = graph.subgraph
        graph.subgraph = self
        defer { graph.subgraph = previousSubgraph }
        return body()
    }

    public func clean() {
        for attributeRef in attributeRefs {
            attributeRef.attribute.state = .clean
            for incomingEdge in attributeRef.attribute.incomingEdges {
                incomingEdge.fromRef.attribute.removeOutgoing(edge: incomingEdge)
                attributeRef.attribute.removeIncoming(edge: incomingEdge)
            }
            for outgoingEdge in attributeRef.attribute.outgoingEdges {
                outgoingEdge.toRef.attribute.removeIncoming(edge: outgoingEdge)
                graph.invalidate(outgoingEdge.toRef)
                attributeRef.attribute.removeOutgoing(edge: outgoingEdge)
            }
            graph.unregister(attributeRef: attributeRef)
        }
        attributeRefs.removeAll()
    }

    func register(attributeRef: AttributeRef) {
        attributeRefs.insert(attributeRef)
    }
}

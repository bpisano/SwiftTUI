//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 17/02/2026.
//

import Foundation

public final class Subgraph {
    private let graph: Graph
    private var attributeIDs: Set<ObjectIdentifier> = []
    private var attributes: [AnyAttribute] = []

    public var attributeLabels: [String] {
        attributes.map(\.label)
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

    public var debugClean: Bool = false

    public func clean() {
        for attribute in attributes {
            attribute.state = .clean
            if debugClean && !attribute.incomingEdges.isEmpty {
                print("[Subgraph.clean] \(attribute.label) — removing \(attribute.incomingEdges.count) incoming edges: \(attribute.incomingEdges.map(\.from.label))")
            }
            for incomingEdge in attribute.incomingEdges {
                incomingEdge.from.removeOutgoing(edge: incomingEdge)
                attribute.removeIncoming(edge: incomingEdge)
            }
            for outgoingEdge in attribute.outgoingEdges {
                outgoingEdge.to.removeIncoming(edge: outgoingEdge)
                graph.invalidate(outgoingEdge.to)
                attribute.removeOutgoing(edge: outgoingEdge)
            }
            graph.unregister(attribute)
        }
        attributes.removeAll()
        attributeIDs.removeAll()
    }

    func register(_ attribute: AnyAttribute) {
        guard attributeIDs.insert(ObjectIdentifier(attribute)).inserted else { return }
        attributes.append(attribute)
    }
}

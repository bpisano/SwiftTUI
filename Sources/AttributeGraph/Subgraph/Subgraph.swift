//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 17/02/2026.
//

import Foundation

@MainActor
public final class Subgraph {
    private let graph: Graph
    private var attributeIDs: Set<ObjectIdentifier> = []
    private var attributes: [AnyAttribute] = []

    private weak var parent: Subgraph?
    private var children: [Subgraph] = []

    public var attributeLabels: [String] {
        attributes.map(\.label)
    }

    public init(graph: Graph = .current) {
        self.graph = graph
        let parent = graph.subgraph
        self.parent = parent
        parent?.children.append(self)
    }

    public func withDependencyCapture<T>(_ body: () -> T) -> T {
        let previousSubgraph: Subgraph? = graph.subgraph
        graph.subgraph = self
        defer { graph.subgraph = previousSubgraph }
        return body()
    }

    public var debugClean: Bool = false

    public func clean() {
        let childrenToClean = children
        children.removeAll()
        for child in childrenToClean {
            child.parent = nil
            child.clean()
        }

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
            attribute.owningSubgraph = nil
        }
        attributes.removeAll()
        attributeIDs.removeAll()

        parent?.removeChild(self)
        parent = nil
    }

    private func removeChild(_ child: Subgraph) {
        children.removeAll { $0 === child }
    }

    func register(_ attribute: AnyAttribute) {
        guard attributeIDs.insert(ObjectIdentifier(attribute)).inserted else { return }
        attributes.append(attribute)
        attribute.owningSubgraph = self
    }
}

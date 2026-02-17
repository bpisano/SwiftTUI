//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 17/02/2026.
//

import Foundation

public final class Subgraph {
    private let graph: Graph
    private var attributeRefs: [AttributeRef] = []

    public init(graph: Graph = .current) {
        self.graph = graph
    }

    public func clean() {
        for attributeRef in attributeRefs {
            for incomingEdge in attributeRef.attribute.incomingEdges {
                incomingEdge.fromRef.attribute.removeOutgoing(edge: incomingEdge)
                attributeRef.attribute.removeIncoming(edge: incomingEdge)
            }
            for outgoingEdge in attributeRef.attribute.outgoingEdges {
                outgoingEdge.toRef.attribute.removeIncoming(edge: outgoingEdge)
                outgoingEdge.toRef.attribute.makePotentiallyDirty()
                attributeRef.attribute.removeOutgoing(edge: outgoingEdge)
            }
            graph.unregister(attributeRef: attributeRef)
        }
        attributeRefs.removeAll()
    }

    func register(attributeRef: AttributeRef) {
        attributeRefs.append(attributeRef)
    }
}

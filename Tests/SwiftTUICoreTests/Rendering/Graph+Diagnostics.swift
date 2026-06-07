//
//  Graph+Diagnostics.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 06/06/2026.
//
//  Test-only diagnostics for the attribute graph: growth counters and structural-coherence
//  checks. They iterate every registered attribute, so they are kept out of the production
//  API surface and live here in the test target.

@testable import AttributeGraph

extension Graph {
    /// Number of attributes currently registered in the graph. Used by growth/leak tests.
    var attributeCount: Int { registeredAttributes.count }

    /// Total number of directed edges across all registered attributes. Used by leak tests.
    var totalEdgeCount: Int {
        registeredAttributes.reduce(0) { $0 + $1.outgoingEdges.count }
    }

    /// Edges held by a registered attribute whose opposite endpoint is no longer registered.
    /// A coherent graph has none: tearing a subgraph down must detach every edge that crossed
    /// its boundary.
    var danglingEdges: [(from: String, to: String)] {
        var result: [(from: String, to: String)] = []
        for attribute in registeredAttributes {
            for edge in attribute.outgoingEdges where !isRegistered(edge.to) {
                result.append((edge.from.label, edge.to.label))
            }
            for edge in attribute.incomingEdges where !isRegistered(edge.from) {
                result.append((edge.from.label, edge.to.label))
            }
        }
        return result
    }

    /// Half-edges: an outgoing edge with no matching incoming edge on its destination, or an
    /// incoming edge with no matching outgoing edge on its source. A coherent graph has none —
    /// every edge is referenced symmetrically by both endpoints.
    var asymmetricEdges: [(from: String, to: String)] {
        var result: [(from: String, to: String)] = []
        for attribute in registeredAttributes {
            for edge in attribute.outgoingEdges where !edge.to.incomingEdges.contains(edge) {
                result.append((edge.from.label, edge.to.label))
            }
            for edge in attribute.incomingEdges where !edge.from.outgoingEdges.contains(edge) {
                result.append((edge.from.label, edge.to.label))
            }
        }
        return result
    }
}

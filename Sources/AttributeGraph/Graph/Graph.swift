//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

public final class Graph {
    public static nonisolated(unsafe) private(set) var current: Graph = .init()

    public var onInvalidate: (() -> Void)?

    public var subgraph: Subgraph?

    private var attributesRefs: Set<AttributeRef> = []
    private var transactionalAttributeRefs: [AttributeRef] = []
    private var currentComputationRef: AttributeRef?
    /// Tracks which source refs have already been registered as dependencies
    /// during the current `withDependencyCapture` session.
    /// Replaces the O(n) linear scan of `outgoingEdges` with an O(1) hash lookup.
    private var capturedDependencies: Set<AttributeRef> = []

    private var tracksTransaction: Bool = false
    private(set) var transaction: Transaction = .init()

    public init() {}

    public func makeCurrent() {
        Graph.current = self
    }

    public func beginTransactionTracking() {
        transaction = .init()
        tracksTransaction = true
    }

    public func endTransactionTracking() -> Transaction {
        tracksTransaction = false
        return transaction
    }

    func register(attributeRef: AttributeRef) {
        attributesRefs.insert(attributeRef)

        if let subgraph {
            subgraph.register(attributeRef: attributeRef)
        }
    }

    func unregister(attributeRef: AttributeRef) {
        attributesRefs.remove(attributeRef)
    }

    func registerDependency(_ attributeRef: AttributeRef) {
        guard let currentComputationRef else { return }

        // O(1) dedup: the set tracks every source already registered in this capture session.
        // This replaces the previous O(n) linear scan over `outgoingEdges` which caused
        // O(n²) behaviour when one source had thousands of dependents.
        guard capturedDependencies.insert(attributeRef).inserted else { return }

        let edge: Edge = .init(from: attributeRef, to: currentComputationRef)
        attributeRef.attribute.addOutgoing(edge: edge)
        currentComputationRef.attribute.addIncoming(edge: edge)
    }

    func withDependencyCapture(
        of attribute: AttributeRef,
        perform: () throws -> Void
    ) rethrows {
        let previousComputationRef: AttributeRef? = currentComputationRef
        let previousDeps = capturedDependencies
        currentComputationRef = attribute
        capturedDependencies = []
        try perform()
        currentComputationRef = previousComputationRef
        capturedDependencies = previousDeps
    }

    /// Marks `attributeRef` as `.dirty` and BFS-propagates `.pending` to all transitive descendants.
    ///
    /// - `.dirty`: direct dependent — must re-evaluate unconditionally.
    /// - `.pending`: transitive descendant — skip if no direct dep actually changed its value.
    ///
    /// Nodes already `.dirty` or `.pending` are not re-traversed, keeping total BFS work O(nodes).
    func markDirty(_ attributeRef: AttributeRef) {
        guard attributeRef.attribute.state != .dirty else { return }
        attributeRef.attribute.state = .dirty

        if tracksTransaction {
            transaction.invalidations.append(attributeRef)
        }

        // Fast path: leaf node has no descendants to propagate .pending to.
        // Avoids allocating a queue array + visited Set for the common fan-out case
        // where all direct dependents are leaves.
        let outgoing = attributeRef.attribute.outgoingEdges
        guard !outgoing.isEmpty else { return }

        var queue: [AttributeRef] = []
        var visited: Set<AttributeRef> = [attributeRef]

        for edge in outgoing {
            let dep = edge.toRef
            if visited.insert(dep).inserted {
                queue.append(dep)
            }
        }

        while !queue.isEmpty {
            let current = queue.removeFirst()
            guard current.attribute.state == .clean else { continue }
            current.attribute.state = .pending

            for edge in current.attribute.outgoingEdges {
                let dep = edge.toRef
                if visited.insert(dep).inserted {
                    queue.append(dep)
                }
            }
        }
    }

    /// Kept for Subgraph.clean(): marks a node and all descendants as invalidated.
    func invalidate(_ attributeRef: AttributeRef) {
        markDirty(attributeRef)
        onInvalidate?()
    }

    func reevaluate(_ attribute: AttributeRef) {
        guard tracksTransaction else { return }
        transaction.reevaluations.append(attribute)
    }
}

extension Graph: DigraphRepresentable {
    public var digraph: String {
        let attributesDescription = attributesRefs
            .map(\.attribute.digraph)
            .joined(separator: "\n    ")
        let edgesDescription = attributesRefs
            .flatMap { ref in
                ref.attribute.outgoingEdges.map(\.digraph)
            }
            .joined(separator: "\n    ")

        return """
            digraph {
                \(attributesDescription)
                \(edgesDescription)
            }
            """
    }
}

extension Graph {
    public struct Transaction {
        var invalidations: [AttributeRef] = []
        var reevaluations: [AttributeRef] = []
    }
}

extension Graph.Transaction: CustomStringConvertible {
    public var description: String {
        let invalidationsDescription =
            invalidations
            .map(\.attribute.label)
            .joined(separator: "\n    ")
        let reevaluationsDescription =
            reevaluations
            .map(\.attribute.label)
            .joined(separator: "\n    ")

        return """
            Transaction:
              Changed:
                \(invalidationsDescription)
              Reevaluated:
                \(reevaluationsDescription)
            """
    }
}

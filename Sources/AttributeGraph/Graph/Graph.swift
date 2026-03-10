//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

public final class Graph {
    public static private(set) var current: Graph = .init()

    public var onInvalidate: (() -> Void)?

    public var subgraph: Subgraph?

    private var attributesRefs: [AttributeRef] = []
    private var transactionalAttributeRefs: [AttributeRef] = []
    private var currentComputationRef: AttributeRef?

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
        // Defensive: avoid registering the same reference twice.
        guard !attributesRefs.contains(where: { $0 === attributeRef }) else {
            return
        }
        guard !attributesRefs.contains(where: { $0.attribute.id == attributeRef.attribute.id }) else {
            return
        }
        attributesRefs.append(attributeRef)

        if let subgraph {
            subgraph.register(attributeRef: attributeRef)
        }
    }

    func unregister(attributeRef: AttributeRef) {
        attributesRefs.removeAll { $0 === attributeRef }
    }

    func registerDependency(_ attributeRef: AttributeRef) {
        guard let currentComputationRef else { return }

        let existingEdge: Edge? = attributeRef.attribute.outgoingEdges
            .first { edge in
                edge.toRef === currentComputationRef
            }
        guard existingEdge == nil else { return }

        let edge: Edge = .init(from: attributeRef, to: currentComputationRef)
        attributeRef.attribute.addOutgoing(edge: edge)
        currentComputationRef.attribute.addIncoming(edge: edge)
    }

    func withDependencyCapture(
        of attribute: AttributeRef,
        perform: () throws -> Void
    ) rethrows {
        let previousComputationRef: AttributeRef? = currentComputationRef
        currentComputationRef = attribute
        try perform()
        currentComputationRef = previousComputationRef
    }

    func invalidate(_ attribute: AttributeRef) {
        onInvalidate?()
        if tracksTransaction {
            transaction.invalidations.append(attribute)
        }
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

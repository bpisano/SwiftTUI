//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

public final class Graph {
    static private(set) var current: Graph = .init()

    public var onInvalidate: (() -> Void)?

    private var attributes: [AttributeRef] = []
    private var transactionalAttributes: [AttributeRef] = []
    private var currentComputation: AttributeRef?

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

    func register(attribute: AttributeRef) {
        attributes.append(attribute)
    }

    func registerDependency(_ attribute: AttributeRef) {
        guard let currentComputation else { return }

        let edge: Edge = .init(from: attribute, to: currentComputation)
        attribute.attribute.addOutgoing(edge: edge)
        currentComputation.attribute.addIncoming(edge: edge)
    }

    func withDependencyCapture(
        of attribute: AttributeRef,
        perform: () throws -> Void
    ) rethrows {
        let previousComputation: AttributeRef? = currentComputation
        currentComputation = attribute
        try perform()
        currentComputation = previousComputation
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

extension Graph: CustomStringConvertible {
    public var description: String {
        let attributesDescription =
            attributes
            .map(\.attribute.description)
            .joined(separator: "\n    ")
        let edgesDescription =
            attributes
            .flatMap { attribute in
                attribute.attribute.outgoingEdges.map(\.description)
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

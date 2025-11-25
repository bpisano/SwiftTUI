//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation
import Playgrounds

public final class Graph {
    static private(set) var current: Graph = .init()

    private var attributes: [AttributeRef] = []
    private var currentComputation: AttributeRef?
    private var newlyCaptureDependencies: Set<UUID>?

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

    func findAttribute(by id: UUID) -> AttributeRef? {
        return attributes.first { $0.ref.id == id }
    }

    func registerDependency(_ attribute: AttributeRef) {
        guard currentComputation != nil else { return }
        // Track this dependency during capture
        newlyCaptureDependencies?.insert(attribute.ref.id)
    }

    func withDependencyCapture(
        of attribute: AttributeRef,
        perform: () throws -> Void
    ) rethrows -> Set<UUID> {
        let previousComputation: AttributeRef? = currentComputation
        let previousCapture: Set<UUID>? = newlyCaptureDependencies

        currentComputation = attribute
        newlyCaptureDependencies = []

        try perform()

        let capturedDependencies = newlyCaptureDependencies ?? []
        currentComputation = previousComputation
        newlyCaptureDependencies = previousCapture

        return capturedDependencies
    }

    func invalidate(_ attribute: AttributeRef) {
        guard tracksTransaction else { return }
        transaction.invalidations.append(attribute)
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
            .map(\.ref.description)
            .joined(separator: "\n    ")
        let edgesDescription =
            attributes
            .flatMap { attribute in
                attribute.ref.outgoingEdges.map(\.description)
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
            .map(\.ref.label)
            .joined(separator: "\n    ")
        let reevaluationsDescription =
            reevaluations
            .map(\.ref.label)
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

#Playground {
    let graph: Graph = .init()
    graph.makeCurrent()

    @Attribute var x = 10
    @Attribute var y = 20

    @Attribute var z = 5
    @Attribute var t = 15

    @Attribute var a = x + y
    @Attribute var b = z + t
    @Attribute var c = a + b

    $a.label = "A"
    $b.label = "B"
    $c.label = "C"
    $x.label = "X"
    $y.label = "Y"
    $z.label = "Z"
    $t.label = "T"

    _ = c

    print(graph.description)  // Initial graph

    graph.beginTransactionTracking()
    x = 3

    print(graph.description)  // Graph after changing 'x'

    _ = c

    print(graph.description)  // Graph after reevaluating 'c'

    let transaction = graph.endTransactionTracking()

    print(transaction)
}

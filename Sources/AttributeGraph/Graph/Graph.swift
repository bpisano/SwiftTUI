//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

/// Task-local storage for the current graph.
/// Declared on a `nonisolated` enum so the macro-generated `$current` projection stays
/// nonisolated and can be read from any actor context (e.g. the SwiftTUIRuntime
/// `nonisolated static func main` entry point or parallel tests).
nonisolated public enum GraphStorage {
    @TaskLocal public static var current: Graph = Graph()
}

@MainActor
public final class Graph {
    public nonisolated static var current: Graph { GraphStorage.current }

    public var onInvalidate: (() -> Void)?

    public var subgraph: Subgraph?

    private var attributes: [ObjectIdentifier: AnyAttribute] = [:]
    private var currentComputation: (AnyAttribute)?
    /// Tracks which source attributes have already been registered as dependencies
    /// during the current `withDependencyCapture` session.
    /// Provides O(1) dedup instead of an O(n) linear scan over `outgoingEdges`.
    private var capturedDependencies: Set<ObjectIdentifier> = []

    private var tracksTransaction: Bool = false
    private(set) var transaction: Transaction = .init()

    public nonisolated init() {}

    /// Binds `graph` as `Graph.current` for the duration of `perform`.
    /// Uses task-local storage so concurrent tasks (e.g. parallel tests, separate render contexts)
    /// each see their own current graph without racing on a shared singleton.
    ///
    /// The `isolation` parameter forwards the caller's actor isolation so `perform`
    /// can call MainActor (or other-actor) APIs without needing to hop.
    public static func withCurrent<T>(
        _ graph: Graph,
        isolation: isolated (any Actor)? = #isolation,
        perform: () throws -> T
    ) rethrows -> T {
        try GraphStorage.$current.withValue(graph, operation: perform)
    }

    public static func withCurrent<T>(
        _ graph: Graph,
        isolation: isolated (any Actor)? = #isolation,
        perform: () async throws -> T
    ) async rethrows -> T {
        try await GraphStorage.$current.withValue(graph, operation: perform)
    }

    /// Total number of registered attributes in the graph. Useful for growth tests.
    public var attributeCount: Int { attributes.count }

    /// Total number of directed edges across all registered attributes. Useful for growth tests.
    public var totalEdgeCount: Int {
        attributes.values.reduce(0) { $0 + $1.outgoingEdges.count }
    }

    /// Returns (label, outgoingEdgeCount) for all attributes that have at least one outgoing edge.
    /// Useful for diagnosing edge accumulation in tests.
    public var outgoingEdgeSummary: [(label: String, count: Int)] {
        attributes.values
            .filter { !$0.outgoingEdges.isEmpty }
            .map { ($0.label, $0.outgoingEdges.count) }
            .sorted { $0.label < $1.label }
    }

    /// Returns all (label, outgoingEdgeCount) for every registered attribute, including those with 0 edges.
    public var allAttributeSummary: [(label: String, outgoing: Int, incoming: Int)] {
        attributes.values
            .map { ($0.label, $0.outgoingEdges.count, $0.incomingEdges.count) }
            .sorted { $0.label < $1.label }
    }

    /// Returns outgoing edge destination labels for the first attribute whose label contains `substr`.
    public func outgoingEdgeDestinations(containing substr: String) -> [(from: String, to: String)] {
        attributes.values
            .filter { $0.label.contains(substr) }
            .flatMap { attr in attr.outgoingEdges.map { (attr.label, $0.to.label) } }
            .sorted { $0.from < $1.from }
    }

    public func beginTransactionTracking() {
        transaction = .init()
        tracksTransaction = true
    }

    public func endTransactionTracking() -> Transaction {
        tracksTransaction = false
        return transaction
    }

    func register(_ attribute: AnyAttribute) {
        attributes[ObjectIdentifier(attribute)] = attribute

        if let subgraph {
            subgraph.register(attribute)
        }
    }

    func unregister(_ attribute: AnyAttribute) {
        attributes.removeValue(forKey: ObjectIdentifier(attribute))
    }

    func isRegistered(_ attribute: AnyAttribute) -> Bool {
        attributes[ObjectIdentifier(attribute)] != nil
    }

    func registerDependency(_ attribute: AnyAttribute) {
        guard let currentComputation else { return }
        guard isRegistered(attribute), isRegistered(currentComputation) else { return }

        // O(1) dedup: the set tracks every source already registered in this capture session.
        // This replaces the previous O(n) linear scan over `outgoingEdges` which caused
        // O(n²) behaviour when one source had thousands of dependents.
        guard capturedDependencies.insert(ObjectIdentifier(attribute)).inserted else { return }

        let edge: Edge = .init(from: attribute, to: currentComputation)
        attribute.addOutgoing(edge: edge)
        currentComputation.addIncoming(edge: edge)
    }

    func withDependencyCapture(
        of attribute: AnyAttribute,
        perform: () throws -> Void
    ) rethrows {
        let previousComputation = currentComputation
        let previousDeps = capturedDependencies
        currentComputation = attribute
        capturedDependencies = []
        defer {
            currentComputation = previousComputation
            capturedDependencies = previousDeps
        }
        try perform()
    }

    /// Marks `attribute` as `.dirty` and BFS-propagates `.pending` to all transitive descendants.
    ///
    /// - `.dirty`: direct dependent — must re-evaluate unconditionally.
    /// - `.pending`: transitive descendant — skip if no direct dep actually changed its value.
    ///
    /// Nodes already `.dirty` or `.pending` are not re-traversed, keeping total BFS work O(nodes).
    func markDirty(_ attribute: AnyAttribute) {
        guard attribute.state != .dirty else { return }
        attribute.state = .dirty
        // Reset the change flag so the pending-skip optimization only fires
        // when this propagation actually produces a new value.
        attribute.didChangeInLatestPropagation = false

        if tracksTransaction {
            transaction.invalidations.append(attribute)
        }

        // Fast path: leaf node has no descendants to propagate .pending to.
        // Avoids allocating a queue array + visited Set for the common fan-out case
        // where all direct dependents are leaves.
        let outgoing = attribute.outgoingEdges
        guard !outgoing.isEmpty else { return }

        var queue: [AnyAttribute] = []
        var visited: Set<ObjectIdentifier> = [ObjectIdentifier(attribute)]

        for edge in outgoing {
            let dep = edge.to
            if visited.insert(ObjectIdentifier(dep)).inserted {
                queue.append(dep)
            }
        }

        while !queue.isEmpty {
            let current = queue.removeFirst()
            guard current.state == .clean else { continue }
            current.state = .pending
            current.didChangeInLatestPropagation = false

            for edge in current.outgoingEdges {
                let dep = edge.to
                if visited.insert(ObjectIdentifier(dep)).inserted {
                    queue.append(dep)
                }
            }
        }
    }

    /// Marks a node and all descendants as invalidated, then notifies the invalidation handler.
    func invalidate(_ attribute: AnyAttribute) {
        markDirty(attribute)
        onInvalidate?()
    }

    func reevaluate(_ attribute: AnyAttribute) {
        guard tracksTransaction else { return }
        transaction.reevaluations.append(attribute)
    }
}

extension Graph: DigraphRepresentable {
    public var digraph: String {
        let attributesDescription = attributes.values
            .map(\.digraph)
            .joined(separator: "\n    ")
        let edgesDescription = attributes.values
            .flatMap(\.outgoingEdges)
            .map(\.digraph)
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
    public nonisolated struct Transaction {
        var invalidations: [AnyAttribute] = []
        var reevaluations: [AnyAttribute] = []

        public init() {}
    }
}

extension Graph.Transaction: @MainActor CustomStringConvertible {
    @MainActor public var description: String {
        let invalidationsDescription =
            invalidations
            .map(\.label)
            .joined(separator: "\n    ")
        let reevaluationsDescription =
            reevaluations
            .map(\.label)
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

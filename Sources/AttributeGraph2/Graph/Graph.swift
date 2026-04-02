import Foundation

public final class Graph {
    public static private(set) var current: Graph = .init()

    public var onInvalidate: (() -> Void)?
    public var subgraph: Subgraph?

    private var attributesRefs: Set<AttributeRef> = []
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
        subgraph?.register(attributeRef: attributeRef)
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

        let edge = Edge(from: attributeRef, to: currentComputationRef)
        attributeRef.attribute.addOutgoing(edge: edge)
        currentComputationRef.attribute.addIncoming(edge: edge)
    }

    func withDependencyCapture(of attribute: AttributeRef, perform: () throws -> Void) rethrows {
        let previous = currentComputationRef
        let previousDeps = capturedDependencies
        currentComputationRef = attribute
        capturedDependencies = []
        try perform()
        currentComputationRef = previous
        capturedDependencies = previousDeps
    }

    /// Marks `attributeRef` as `.dirty` and propagates `.pending` to all transitive descendants.
    ///
    /// - `.dirty` means "direct dependency confirmed changed — must re-evaluate".
    /// - `.pending` means "transitive ancestor changed — check direct deps before deciding".
    ///
    /// Nodes already `.dirty` are not downgraded.
    func markDirty(_ attributeRef: AttributeRef) {
        guard attributeRef.attribute.state != .dirty else { return }
        attributeRef.attribute.state = .dirty

        if tracksTransaction {
            transaction.invalidations.append(attributeRef)
        }

        // BFS: mark all transitive descendants as .pending.
        var queue: [AttributeRef] = []
        var visited: Set<AttributeRef> = [attributeRef]

        for edge in attributeRef.attribute.outgoingEdges {
            let dep = edge.toRef
            if !visited.contains(dep) {
                visited.insert(dep)
                queue.append(dep)
            }
        }

        while !queue.isEmpty {
            let current = queue.removeFirst()

            // Only continue traversal from clean nodes: a node that is already
            // .pending or .dirty was already visited by an earlier markDirty call
            // and its entire subtree has already been (or will be) marked.
            // Skipping non-clean nodes makes the total BFS work O(nodes) across
            // all markDirty calls instead of O(edges × depth).
            guard current.attribute.state == .clean else { continue }
            current.attribute.state = .pending

            for edge in current.attribute.outgoingEdges {
                let dep = edge.toRef
                if !visited.contains(dep) {
                    visited.insert(dep)
                    queue.append(dep)
                }
            }
        }
    }

    func reevaluate(_ attribute: AttributeRef) {
        guard tracksTransaction else { return }
        transaction.reevaluations.append(attribute)
    }
}

// MARK: - Transaction

extension Graph {
    public struct Transaction {
        var invalidations: [AttributeRef] = []
        var reevaluations: [AttributeRef] = []
    }
}

extension Graph.Transaction: CustomStringConvertible {
    public var description: String {
        let inv = invalidations.map(\.attribute.label).joined(separator: "\n    ")
        let reev = reevaluations.map(\.attribute.label).joined(separator: "\n    ")
        return """
            Transaction:
              Invalidated:
                \(inv)
              Reevaluated:
                \(reev)
            """
    }
}

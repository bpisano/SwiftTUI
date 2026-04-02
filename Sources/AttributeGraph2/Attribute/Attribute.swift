import Foundation

@propertyWrapper
public struct Attribute<T>: AnyAttribute {

    // MARK: - wrappedValue

    public var wrappedValue: T {
        get {
            Graph.current.registerDependency(storage.ref)

            if let cachedValue = storage.value, storage.state == .clean {
                return cachedValue
            }

            evaluateIfNeeded()

            precondition(storage.value != nil, "Attribute value should have been evaluated")
            return storage.value!
        }
        nonmutating set {
            // Equality short-circuit: if the new value is equal to the current one,
            // skip all dirty propagation entirely.
            if let check = storage.equalityCheck,
               let old = storage.value,
               check.isEqual(old, newValue) {
                return
            }

            storage.value = newValue

            // Direct dependents become .dirty (their direct dependency confirmed changed).
            // Their transitive descendants are marked .pending inside markDirty.
            for edge in outgoingEdges {
                Graph.current.markDirty(edge.toRef)
            }
            // Notify even when there are no outgoing edges: the value itself changed.
            Graph.current.onInvalidate?()
        }
    }

    public var projectedValue: Attribute<T> {
        get { self }
        set { self = newValue }
    }

    public var unsafeValue: T {
        if let value = storage.value { return value }
        return rule.evaluate()
    }

    // MARK: - AnyAttribute

    public var id: UUID {
        get { storage.id }
        nonmutating set { storage.id = newValue }
    }

    public var label: String {
        get { storage.label }
        nonmutating set { storage.label = newValue }
    }

    public var incomingEdges: Set<Edge> {
        get { storage.incomingEdges }
        nonmutating set { storage.incomingEdges = newValue }
    }

    public var outgoingEdges: Set<Edge> {
        get { storage.outgoingEdges }
        nonmutating set { storage.outgoingEdges = newValue }
    }

    public var state: AttributeState {
        get { storage.state }
        nonmutating set { storage.state = newValue }
    }

    public func addIncoming(edge: Edge) { storage.incomingEdges.insert(edge) }
    public func addOutgoing(edge: Edge) { storage.outgoingEdges.insert(edge) }
    public func removeIncoming(edge: Edge) { storage.incomingEdges.remove(edge) }
    public func removeOutgoing(edge: Edge) { storage.outgoingEdges.remove(edge) }

    // MARK: - Internals

    private let rule: AnyRule<T>
    private let storage: Storage = .init()

    // MARK: - Init (non-Equatable)

    public init(
        wrappedValue: @autoclosure @escaping () -> T,
        _ label: String? = nil
    ) {
        self.rule = AnyRule(ValueRule(wrappedValue))
        self.storage.ref = AttributeRef(self)
        self.storage.label = label ?? ""
        Graph.current.register(attributeRef: storage.ref)
    }

    public init(wrappedValue: @autoclosure @escaping () -> T) {
        self.rule = AnyRule(ValueRule(wrappedValue))
        self.storage.ref = AttributeRef(self)
        Graph.current.register(attributeRef: storage.ref)
    }

    public init<R: Rule>(_ label: String? = nil, rule: R) where R.Value == T {
        self.rule = AnyRule(rule)
        self.storage.ref = AttributeRef(self)
        self.storage.label = label ?? ""
        Graph.current.register(attributeRef: storage.ref)
    }

    // MARK: - Evaluation

    /// Iterative post-order evaluation.
    ///
    /// Builds a post-order list of dirty/pending nodes starting from `self` (dependencies
    /// before dependents), then evaluates each node with the `.pending` optimization:
    /// a `.pending` node is skipped if none of its direct dependencies changed their value.
    public func evaluateIfNeeded() {
        // Initial evaluation: no edges registered yet, evaluate self directly.
        if storage.value == nil {
            _ = evaluateSelf()
            return
        }

        guard state != .clean else { return }

        let postOrder = collectPostOrder()
        var changedRefs: Set<AttributeRef> = []

        for ref in postOrder {
            // .pending optimization: skip if no direct dependency actually changed.
            // Access through ref.attribute to ensure mutations write back to the stored existential.
            if ref.attribute.state == .pending {
                let anyDirectDepChanged = ref.attribute.incomingEdges.contains {
                    changedRefs.contains($0.fromRef)
                }
                if !anyDirectDepChanged {
                    ref.attribute.state = .clean
                    continue
                }
            }

            if ref.attribute.evaluateSelf() {
                changedRefs.insert(ref)
            }
        }
    }

    /// Builds a post-order list of nodes that need evaluation, starting from `self`.
    ///
    /// Uses iterative DFS with an "expanded" flag to produce a valid topological order
    /// (dependencies before their dependents). Only includes `.dirty` and `.pending` nodes.
    private func collectPostOrder() -> [AttributeRef] {
        var result: [AttributeRef] = []
        var visited: Set<AttributeRef> = []
        var stack: [(ref: AttributeRef, expanded: Bool)] = [(storage.ref, false)]

        while !stack.isEmpty {
            let (ref, expanded) = stack.removeLast()

            if expanded {
                if !visited.contains(ref) {
                    visited.insert(ref)
                    result.append(ref)
                }
                continue
            }

            if visited.contains(ref) || ref.attribute.state == .clean { continue }

            // Push self again to finalize after all deps are processed.
            stack.append((ref, true))

            for edge in ref.attribute.incomingEdges {
                let dep = edge.fromRef
                if !visited.contains(dep) && dep.attribute.state != .clean {
                    stack.append((dep, false))
                }
            }
        }

        return result
    }

    /// Evaluates the underlying rule for this node and returns whether the value changed.
    ///
    /// Before evaluation, all stale incoming edges are cleared and re-registered fresh
    /// during rule execution (stale edge pruning). After evaluation, an optional equality
    /// check determines whether to report a change, enabling the change-cut optimization.
    public func evaluateSelf() -> Bool {
        let oldValue = storage.value

        // Stale edge pruning: clear all incoming edges before re-evaluation.
        // New edges will be re-registered during rule execution via dependency capture.
        for edge in storage.incomingEdges {
            edge.fromRef.attribute.removeOutgoing(edge: edge)
        }
        storage.incomingEdges.removeAll()

        Graph.current.reevaluate(storage.ref)
        Graph.current.withDependencyCapture(of: storage.ref) {
            storage.value = rule.evaluate()
        }

        storage.state = .clean

        for edge in storage.incomingEdges {
            edge.state = .clean
        }

        // Initial evaluation always counts as a change.
        guard let oldValue else { return true }

        // Equality check: if the value didn't change, stop propagation (change cut).
        if let check = storage.equalityCheck {
            return !check.isEqual(oldValue, storage.value!)
        }

        return true
    }
}

// MARK: - Equatable-constrained init

// The constrained versions set an equality check, enabling the short-circuit in the
// setter and the change-cut after rule evaluation.
extension Attribute where T: Equatable {
    public init(
        wrappedValue: @autoclosure @escaping () -> T,
        _ label: String? = nil
    ) {
        self.rule = AnyRule(ValueRule(wrappedValue))
        self.storage.ref = AttributeRef(self)
        self.storage.label = label ?? ""
        self.storage.equalityCheck = EquatableComparator<T>()
        Graph.current.register(attributeRef: storage.ref)
    }

    public init(wrappedValue: @autoclosure @escaping () -> T) {
        self.rule = AnyRule(ValueRule(wrappedValue))
        self.storage.ref = AttributeRef(self)
        self.storage.equalityCheck = EquatableComparator<T>()
        Graph.current.register(attributeRef: storage.ref)
    }

    public init<R: Rule>(_ label: String? = nil, rule: R) where R.Value == T {
        self.rule = AnyRule(rule)
        self.storage.ref = AttributeRef(self)
        self.storage.label = label ?? ""
        self.storage.equalityCheck = EquatableComparator<T>()
        Graph.current.register(attributeRef: storage.ref)
    }
}

// MARK: - ComputedRule convenience

extension Attribute {
    public init(_ label: String? = nil, _ compute: @escaping () -> T) {
        self.init(label, rule: ComputedRule(compute))
    }
}

extension Attribute where T: Equatable {
    public init(_ label: String? = nil, _ compute: @escaping () -> T) {
        self.init(label, rule: ComputedRule(compute))
    }
}

// MARK: - MappedRule convenience

extension Attribute {
    public func map<U>(_ transform: @escaping (T) -> U) -> Attribute<U> {
        Attribute<U>(rule: MappedRule(parent: self, transform: transform))
    }

    public func map<U>(_ keyPath: KeyPath<T, U>) -> Attribute<U> {
        map { $0[keyPath: keyPath] }
    }
}

struct MappedRule<T, U>: Rule {
    let parent: Attribute<T>
    let transform: (T) -> U

    func evaluate() -> U {
        transform(parent.wrappedValue)
    }
}

// MARK: - Storage

extension Attribute {
    final class Storage {
        var id: UUID = .init()
        var ref: AttributeRef!
        var label: String = ""
        var value: T?
        var incomingEdges: Set<Edge> = []
        var outgoingEdges: Set<Edge> = []
        var state: AttributeState = .clean
        /// Type-erased equality check. Set automatically for `T: Equatable` types.
        var equalityCheck: (any EqualityComparator<T>)?
    }
}

//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

@propertyWrapper
public struct Attribute<T>: AnyAttribute {
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
            // Equality short-circuit: if the new value equals the current one,
            // skip all dirty propagation entirely.
            if let check = storage.equalityCheck,
               let old = storage.value,
               check.isEqual(old, newValue) {
                return
            }

            storage.value = newValue

            // Collect transactional refs before the BFS loop to avoid interleaving
            // evaluateIfNeeded calls with the markDirty propagation.
            var transactionalRefs: [AttributeRef] = []
            for edge in outgoingEdges {
                // markDirty sets the dependent .dirty and BFS-marks its descendants .pending.
                Graph.current.markDirty(edge.toRef)
                if edge.toRef.attribute.flags.contains(.transactional) {
                    transactionalRefs.append(edge.toRef)
                }
            }
            // Transactional attributes must be evaluated eagerly, right now.
            for ref in transactionalRefs {
                ref.attribute.evaluateIfNeeded()
            }
            Graph.current.onInvalidate?()
        }
    }

    public var projectedValue: Attribute<T> {
        get {
            self
        }
        set {
            self = newValue
        }
    }

    public var unsafeValue: T {
        if let value = storage.value {
            return value
        }
        return rule.evaluate()
    }

    public var id: UUID {
        get { storage.id }
        nonmutating set { storage.id = newValue }
    }

    public var flags: AttributeFlags {
        get { storage.flags }
        nonmutating set { storage.flags = newValue }
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

    private let rule: AnyRule<T>
    private let storage: Storage = .init()

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

    public init<R: Rule>(
        _ label: String? = nil,
        rule: R
    ) where R.Value == T {
        self.rule = AnyRule(rule)
        self.storage.ref = AttributeRef(self)
        self.storage.label = label ?? ""
        Graph.current.register(attributeRef: storage.ref)
    }

    public func addIncoming(edge: Edge) {
        storage.incomingEdges.insert(edge)
    }

    public func addOutgoing(edge: Edge) {
        storage.outgoingEdges.insert(edge)
    }

    public func removeIncoming(edge: Edge) {
        storage.incomingEdges.remove(edge)
    }

    public func removeOutgoing(edge: Edge) {
        storage.outgoingEdges.remove(edge)
    }

    public func evaluateIfNeeded() {
        // Initial evaluation: no edges registered yet, evaluate self directly.
        if storage.value == nil {
            _ = evaluateSelf()
            return
        }

        guard state != .clean else { return }

        // Fast path: a .dirty leaf (no outgoing edges) can be evaluated directly
        // without allocating a post-order list, a changedRefs Set, or a DFS stack.
        // This is the common case for all terminal nodes in a fan-out graph.
        if state == .dirty && storage.outgoingEdges.isEmpty {
            _ = evaluateSelf()
            return
        }

        let postOrder = collectPostOrder()
        var changedRefs: Set<AttributeRef> = []

        for ref in postOrder {
            // .pending optimization: skip if no direct dependency actually changed.
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

    /// Evaluates the underlying rule and returns whether the value changed.
    ///
    /// Prunes stale incoming edges before re-running so that conditional dependencies
    /// are re-registered correctly. Returns `true` if the value changed (enabling change-cut).
    public func evaluateSelf() -> Bool {
        let oldValue = storage.value

        // Stale edge pruning: clear incoming edges so re-evaluation registers only
        // the deps the rule actually reads this time.
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

        guard let oldValue else { return true }

        if let check = storage.equalityCheck {
            return !check.isEqual(oldValue, storage.value!)
        }

        return true
    }
}

extension Attribute {
    final class Storage: @unchecked Sendable {
        var id: UUID = .init()
        var ref: AttributeRef!
        var flags: AttributeFlags = []
        var label: String = ""
        var value: T?
        var incomingEdges: Set<Edge> = []
        var outgoingEdges: Set<Edge> = []
        var state: AttributeState = .clean
        var equalityCheck: (any EqualityComparator<T>)?
    }
}

extension Attribute {
    public var digraph: String {
        let formattedId: String = storage.id.uuidString.replacing("-", with: "")
        var properties: [String] = []

        var labelHTML = "<"
        labelHTML += "<TABLE BORDER=\"0\" CELLBORDER=\"0\" CELLSPACING=\"0\" ALIGN=\"LEFT\">"

        if !storage.label.isEmpty {
            let escapedLabel = storage.label.htmlEscaped
            labelHTML += "<TR><TD ALIGN=\"LEFT\"><B>\(escapedLabel)</B></TD></TR>"
        }

        if let value = storage.value {
            let stringValue: String = if let value = value as? AttributeValueRepresentable {
                "\(value.attributeValueDescription)".htmlEscaped
            } else {
                "\(value)".htmlEscaped
            }
            labelHTML += "<TR><TD ALIGN=\"LEFT\"><FONT POINT-SIZE=\"10\">\(stringValue)</FONT></TD></TR>"
        }

        let shortId: String = String(formattedId.prefix(8)).lowercased()
        labelHTML +=
            "<TR><TD ALIGN=\"LEFT\"><FONT POINT-SIZE=\"8\" COLOR=\"#888888\">\(shortId)</FONT></TD></TR>"

        labelHTML += "</TABLE>"
        labelHTML += ">"
        properties.append("label=\(labelHTML)")

        if storage.state == .pending || storage.state == .dirty {
            properties.append("style=dashed")
        }
        let formattedProperties: String = properties.joined(separator: ", ")
        return "\"\(formattedId)\" [\(formattedProperties)]"
    }
}

extension String {
    fileprivate var htmlEscaped: String {
        self
            .replacing("&", with: "&amp;")
            .replacing("<", with: "&lt;")
            .replacing(">", with: "&gt;")
            .replacing("\n", with: "<br />")
    }
}

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

    public init<R: Rule>(
        _ label: String? = nil,
        rule: R
    ) where R.Value == T {
        self.rule = AnyRule(rule)
        self.storage.ref = AttributeRef(self)
        self.storage.label = label ?? ""
        self.storage.equalityCheck = EquatableComparator<T>()
        Graph.current.register(attributeRef: storage.ref)
    }

    /// Equatable-constrained closure init: sets the equality check so that
    /// `evaluateSelf()` can return `false` (no change) when value is unchanged.
    public init(
        _ label: String? = nil,
        _ compute: @escaping () -> T
    ) {
        self.init(label, rule: ComputedRule(compute))
    }
}

extension Attribute: Sendable where T: Sendable {}

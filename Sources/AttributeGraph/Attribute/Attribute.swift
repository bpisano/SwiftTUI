//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

@MainActor
@propertyWrapper
public final class Attribute<T>: AnyAttribute {
    public var wrappedValue: T {
        get {
            Graph.current.registerDependency(self)

            if let cachedValue = value, state == .clean {
                return cachedValue
            }

            evaluateIfNeeded()

            precondition(value != nil, "Attribute value should have been evaluated")

            return value!
        }
        set {
            // Equality short-circuit: if the new value equals the current one,
            // skip all dirty propagation entirely.
            if let check = equalityCheck,
               let old = value,
               check.isEqual(old, newValue) {
                return
            }

            value = newValue

            // Collect transactional attributes before the BFS loop to avoid interleaving
            // evaluateIfNeeded calls with the markDirty propagation.
            var transactionals: [AnyAttribute] = []
            for edge in outgoingEdges {
                Graph.current.markDirty(edge.to)
                if edge.to.flags.contains(.transactional) {
                    transactionals.append(edge.to)
                }
            }
            // Transactional attributes must be evaluated eagerly, right now.
            for attr in transactionals {
                attr.evaluateIfNeeded()
            }
            Graph.current.onInvalidate?()
        }
    }

    public var projectedValue: Attribute<T> { self }

    public var unsafeValue: T {
        if let value {
            return value
        }
        let computed: T = rule.evaluate()
        value = computed
        return computed
    }

    public var id: UUID = .init()
    public var flags: AttributeFlags = []
    public var label: String = ""
    public var incomingEdges: Set<Edge> = []
    public var outgoingEdges: Set<Edge> = []
    public var state: AttributeState = .clean

    /// Whether the most recent evaluation produced a value different from the
    /// previous one. Set by `evaluateSelf`, cleared by `markDirty`.
    /// Used by the pending-skip optimization across multiple `evaluateIfNeeded`
    /// passes (e.g. when displayList and focusList are read separately).
    public var didChangeInLatestPropagation: Bool = false

    private let rule: AnyRule<T>
    var value: T?
    var equalityCheck: (any EqualityComparator<T>)?

    /// Single designated initializer. All public inits delegate here.
    internal init(
        _ rule: AnyRule<T>,
        label: String,
        equalityCheck: (any EqualityComparator<T>)?
    ) {
        self.rule = rule
        self.label = label
        self.equalityCheck = equalityCheck
        Graph.current.register(self)
    }

    public convenience init(
        wrappedValue: @autoclosure @escaping () -> T,
        _ label: String? = nil
    ) {
        self.init(AnyRule(ValueRule(wrappedValue)), label: label ?? "", equalityCheck: nil)
    }

    public convenience init(wrappedValue: @autoclosure @escaping () -> T) {
        self.init(AnyRule(ValueRule(wrappedValue)), label: "", equalityCheck: nil)
    }

    public convenience init<R: Rule>(
        _ label: String? = nil,
        rule: R
    ) where R.Value == T {
        self.init(AnyRule(rule), label: label ?? "", equalityCheck: nil)
    }

    public func addIncoming(edge: Edge) {
        incomingEdges.insert(edge)
    }

    public func addOutgoing(edge: Edge) {
        outgoingEdges.insert(edge)
    }

    public func removeIncoming(edge: Edge) {
        incomingEdges.remove(edge)
    }

    public func removeOutgoing(edge: Edge) {
        outgoingEdges.remove(edge)
    }

    public func evaluateIfNeeded() {
        // Initial evaluation: no edges registered yet, evaluate self directly.
        if value == nil {
            _ = evaluateSelf()
            return
        }

        guard state != .clean else { return }

        // Fast path: a .dirty leaf (no outgoing edges) can be evaluated directly
        // without allocating a post-order list or a DFS stack.
        // Common case for terminal nodes in a fan-out graph.
        if state == .dirty && outgoingEdges.isEmpty {
            _ = evaluateSelf()
            return
        }

        let postOrder = collectPostOrder()

        for attr in postOrder {
            // .pending optimization: skip when no incoming dep actually changed
            // in the latest dirty propagation. The `didChangeInLatestPropagation`
            // flag persists across `evaluateIfNeeded` calls (cleared by
            // `markDirty`) so that changes observed during a prior read pass
            // (e.g. focusList) still propagate to a subsequent read pass
            // (e.g. displayList).
            if attr.state == .pending {
                let anyDirectDepChanged = attr.incomingEdges.contains(where: {
                    $0.from.didChangeInLatestPropagation
                })
                if !anyDirectDepChanged {
                    attr.state = .clean
                    continue
                }
            }

            _ = attr.evaluateSelf()
        }
    }

    /// Builds a post-order list of nodes that need evaluation, starting from `self`.
    ///
    /// Uses iterative DFS with an "expanded" flag to produce a valid topological order
    /// (dependencies before their dependents). Only includes `.dirty` and `.pending` nodes.
    private func collectPostOrder() -> [AnyAttribute] {
        var result: [AnyAttribute] = []
        var visited: Set<ObjectIdentifier> = []
        var stack: [(attr: AnyAttribute, expanded: Bool)] = [(self, false)]

        while !stack.isEmpty {
            let (attr, expanded) = stack.removeLast()
            let attrID = ObjectIdentifier(attr)

            if expanded {
                if visited.insert(attrID).inserted {
                    result.append(attr)
                }
                continue
            }

            if visited.contains(attrID) || attr.state == .clean { continue }

            stack.append((attr, true))

            for edge in attr.incomingEdges {
                let dep = edge.from
                let depID = ObjectIdentifier(dep)
                if !visited.contains(depID) && dep.state != .clean {
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
        let oldValue = value

        // Stale edge pruning: clear incoming edges so re-evaluation registers only
        // the deps the rule actually reads this time.
        for edge in incomingEdges {
            edge.from.removeOutgoing(edge: edge)
        }
        incomingEdges.removeAll()

        Graph.current.reevaluate(self)
        Graph.current.withDependencyCapture(of: self) {
            value = rule.evaluate()
        }

        state = .clean

        for edge in incomingEdges {
            edge.state = .clean
        }

        let changed: Bool
        if let oldValue {
            if let check = equalityCheck {
                changed = !check.isEqual(oldValue, value!)
            } else {
                changed = true
            }
        } else {
            changed = true
        }

        didChangeInLatestPropagation = changed
        return changed
    }
}

extension Attribute {
    public var digraph: String {
        let formattedId: String = id.uuidString.replacing("-", with: "")
        var properties: [String] = []

        var labelHTML = "<"
        labelHTML += "<TABLE BORDER=\"0\" CELLBORDER=\"0\" CELLSPACING=\"0\" ALIGN=\"LEFT\">"

        if !label.isEmpty {
            let escapedLabel = label.htmlEscaped
            labelHTML += "<TR><TD ALIGN=\"LEFT\"><B>\(escapedLabel)</B></TD></TR>"
        }

        if let value {
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

        if state == .pending || state == .dirty {
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
    public convenience init(
        wrappedValue: @autoclosure @escaping () -> T,
        _ label: String? = nil
    ) {
        self.init(AnyRule(ValueRule(wrappedValue)), label: label ?? "", equalityCheck: EquatableComparator<T>())
    }

    public convenience init(wrappedValue: @autoclosure @escaping () -> T) {
        self.init(AnyRule(ValueRule(wrappedValue)), label: "", equalityCheck: EquatableComparator<T>())
    }

    public convenience init<R: Rule>(
        _ label: String? = nil,
        rule: R
    ) where R.Value == T {
        self.init(AnyRule(rule), label: label ?? "", equalityCheck: EquatableComparator<T>())
    }

    /// Equatable-constrained closure init: sets the equality check so that
    /// `evaluateSelf()` can return `false` (no change) when value is unchanged.
    public convenience init(
        _ label: String? = nil,
        _ compute: @escaping () -> T
    ) {
        self.init(AnyRule(ComputedRule(compute)), label: label ?? "", equalityCheck: EquatableComparator<T>())
    }
}

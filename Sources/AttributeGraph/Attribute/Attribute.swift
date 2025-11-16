//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

@propertyWrapper
public struct Attribute<T>: @MainActor AnyAttribute {
    public var wrappedValue: T {
        get {
            Graph.current.registerDependency(AttributeRef(self))

            if let cachedValue = metadata.value, metadata.state != .potentiallyDirty {
                return cachedValue
            }

            evaluateIfNeeded()

            precondition(metadata.value != nil, "Attribute value should have been evaluated")

            return metadata.value!
        }
        nonmutating set {
            Graph.current.invalidate(ref)
            metadata.value = newValue
            for edge in outgoingEdges {
                edge.state = .dirty
                edge.to.ref.makePotentiallyDirty()
            }
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

    public var id: UUID {
        get {
            metadata.id
        }
        nonmutating set {
            metadata.id = newValue
        }
    }

    public var label: String {
        get {
            metadata.label
        }
        nonmutating set {
            metadata.label = newValue
        }
    }

    var incomingEdges: [Edge] {
        get {
            metadata.incomingEdges
        }
        nonmutating set {
            metadata.incomingEdges = newValue
        }
    }

    var outgoingEdges: [Edge] {
        get {
            metadata.outgoingEdges
        }
        nonmutating set {
            metadata.outgoingEdges = newValue
        }
    }

    private let rule: AnyRule<T>
    private let metadata: Metadata = .init()
    private var ref: AttributeRef!

    public init(wrappedValue: @autoclosure @escaping () -> T) {
        self.rule = AnyRule(ValueRule(wrappedValue))
        self.ref = AttributeRef(self)
        Graph.current.register(attribute: ref)
    }

    public init<R: Rule>(rule: R) where R.Value == T {
        self.rule = AnyRule(rule)
        self.ref = AttributeRef(self)
        Graph.current.register(attribute: ref)
    }

    func addIncoming(edge: Edge) {
        incomingEdges.append(edge)
    }

    func addOutgoing(edge: Edge) {
        outgoingEdges.append(edge)
    }

    func evaluateIfNeeded() {
        // Ensure all dependencies are up to date
        for edge in incomingEdges {
            edge.from.ref.evaluateIfNeeded()
        }

        // Check if any incoming edge is still pending
        // Or if is initial evaluation
        let isInitialEvaluation: Bool = metadata.value == nil
        guard metadata.state == .potentiallyDirty || isInitialEvaluation else { return }

        metadata.state = .clean

        // Evaluate the rule within dependency capture context
        Graph.current.reevaluate(ref)
        print("Re-evaluating attribute \(metadata.label)")
        if isInitialEvaluation {
            Graph.current.withDependencyCapture(of: ref) {
                metadata.value = rule.evaluate()
            }
        } else {
            metadata.value = rule.evaluate()
        }

        if !isInitialEvaluation {
            // Mark incoming edges as clean
            for edge in incomingEdges {
                edge.state = .clean
            }

            // Mark outgoing edges as dirty
            for edge in outgoingEdges {
                edge.state = .dirty
            }
        }
    }

    func makePotentiallyDirty() {
        metadata.state = .potentiallyDirty
        for edge in outgoingEdges {
            edge.to.ref.makePotentiallyDirty()
        }
    }
}

extension Attribute {
    final class Metadata {
        var id: UUID = .init()
        var label: String = ""
        var value: T?
        var incomingEdges: [Edge] = []
        var outgoingEdges: [Edge] = []
        var state: State = .clean
    }

    enum State {
        case clean
        case potentiallyDirty
    }
}

extension Attribute {
    public var description: String {
        let formattedId: String = metadata.id.uuidString.replacingOccurrences(of: "-", with: "")
        var properties: [String] = []
        if !metadata.label.isEmpty {
            properties.append("label=\"\(metadata.label)\"")
        }
        if metadata.state == .potentiallyDirty {
            properties.append("style=dashed")
        }
        let formattedProperties: String = properties.joined(separator: ", ")
        return "\"\(formattedId)\" [\(formattedProperties)]"
    }
}

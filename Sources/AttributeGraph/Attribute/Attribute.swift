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
            Graph.current.registerDependency(storage.ref)

            if let cachedValue = storage.value, storage.state != .potentiallyDirty {
                return cachedValue
            }

            evaluateIfNeeded()

            precondition(storage.value != nil, "Attribute value should have been evaluated")

            return storage.value!
        }
        nonmutating set {
            Graph.current.invalidate(storage.ref)
            storage.value = newValue
            for edge in outgoingEdges {
                edge.state = .dirty

                if edge.toRef.attribute.flags.contains(.transactional) {
                    edge.toRef.attribute.evaluateIfNeeded()
                } else {
                    edge.toRef.attribute.makePotentiallyDirty()
                }
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
            storage.id
        }
        nonmutating set {
            storage.id = newValue
        }
    }

    public var flags: Set<AttributeFlag> {
        get {
            storage.flags
        }
        nonmutating set {
            storage.flags = newValue
        }
    }

    public var label: String {
        get {
            storage.label
        }
        nonmutating set {
            storage.label = newValue
        }
    }

    var incomingEdges: [Edge] {
        get {
            storage.incomingEdges
        }
        nonmutating set {
            storage.incomingEdges = newValue
        }
    }

    var outgoingEdges: [Edge] {
        get {
            storage.outgoingEdges
        }
        nonmutating set {
            storage.outgoingEdges = newValue
        }
    }

    private let rule: AnyRule<T>
    private let storage: Storage = .init()

    public init(wrappedValue: @autoclosure @escaping () -> T) {
        self.rule = AnyRule(ValueRule(wrappedValue))
        self.storage.ref = AttributeRef(self)
        Graph.current.register(attribute: storage.ref)
    }

    public init<R: Rule>(rule: R) where R.Value == T {
        self.rule = AnyRule(rule)
        self.storage.ref = AttributeRef(self)
        Graph.current.register(attribute: storage.ref)
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
            edge.fromRef.attribute.evaluateIfNeeded()
        }

        // Check if any incoming edge is still pending
        // Or if is initial evaluation
        let isInitialEvaluation: Bool = storage.value == nil
        let isTransactional: Bool = flags.contains(.transactional)
        guard storage.state == .potentiallyDirty || isInitialEvaluation || isTransactional else { return }

        storage.state = .clean

        // Evaluate the rule within dependency capture context
        Graph.current.reevaluate(storage.ref)
        if isInitialEvaluation {
            Graph.current.withDependencyCapture(of: storage.ref) {
                storage.value = rule.evaluate()
            }
        } else {
            storage.value = rule.evaluate()
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
        if flags.contains(.transactional) {
            evaluateIfNeeded()
        } else {
            storage.state = .potentiallyDirty
        }

        for edge in outgoingEdges {
            edge.toRef.attribute.makePotentiallyDirty()
        }
    }
}

extension Attribute {
    final class Storage {
        var id: UUID = .init()
        var ref: AttributeRef!
        var flags: Set<AttributeFlag> = []
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
        let formattedId: String = storage.id.uuidString.replacingOccurrences(
            of: "-",
            with: ""
        )
        var properties: [String] = []

        // Build HTML-like label for better formatting
        if !storage.label.isEmpty || storage.value != nil {
            var labelHTML = "<"
            labelHTML += "<TABLE BORDER=\"0\" CELLBORDER=\"0\" CELLSPACING=\"0\">"

            if !storage.label.isEmpty {
                let escapedLabel = storage.label
                    .replacingOccurrences(of: "&", with: "&amp;")
                    .replacingOccurrences(of: "<", with: "&lt;")
                    .replacingOccurrences(of: ">", with: "&gt;")
                labelHTML += "<TR><TD><B>\(escapedLabel)</B></TD></TR>"
            }

            if let value = storage.value {
                labelHTML += "<TR><TD><FONT POINT-SIZE=\"10\">\(value)</FONT></TD></TR>"
            }

            labelHTML += "</TABLE>"
            labelHTML += ">"
            properties.append("label=\(labelHTML)")
        }

        if storage.state == .potentiallyDirty {
            properties.append("style=dashed")
        }
        let formattedProperties: String = properties.joined(separator: ", ")
        return "\"\(formattedId)\" [\(formattedProperties)]"
    }
}

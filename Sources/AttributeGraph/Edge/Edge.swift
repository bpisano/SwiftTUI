//
//  Edge.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

public final class Edge {
    enum State {
        case clean
        case dirty
    }

    let id: UUID = .init()
    let fromRef: AttributeRef
    let toRef: AttributeRef
    var state: State = .clean

    init(
        from: AttributeRef,
        to: AttributeRef
    ) {
        self.fromRef = from
        self.toRef = to
    }
}

extension Edge: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        lhs.id == rhs.id
    }
}

extension Edge: DigraphRepresentable {
    public var digraph: String {
        let fromId: String = fromRef.attribute.id.uuidString.replacingOccurrences(of: "-", with: "")
        let toId: String = toRef.attribute.id.uuidString.replacingOccurrences(of: "-", with: "")
        return "\"\(fromId)\" -> \"\(toId)\"\(state == .dirty ? " [style=dashed]" : "")"
    }
}

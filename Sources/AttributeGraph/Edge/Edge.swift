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

    let from: AnyAttribute
    let to: AnyAttribute
    var state: State = .clean

    init(
        from: AnyAttribute,
        to: AnyAttribute
    ) {
        self.from = from
        self.to = to
    }
}

extension Edge: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        lhs === rhs
    }
}

extension Edge: DigraphRepresentable {
    public var digraph: String {
        let fromId: String = from.id.uuidString.replacingOccurrences(of: "-", with: "")
        let toId: String = to.id.uuidString.replacingOccurrences(of: "-", with: "")
        return "\"\(fromId)\" -> \"\(toId)\"\(state == .dirty ? " [style=dashed]" : "")"
    }
}

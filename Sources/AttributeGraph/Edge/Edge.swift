//
//  Edge.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

final class Edge {
    enum State {
        case clean
        case dirty
    }

    let from: AttributeRef
    let to: AttributeRef
    var state: State = .clean

    init(
        from: AttributeRef,
        to: AttributeRef
    ) {
        self.from = from
        self.to = to
    }

    init(
        from: AnyAttribute,
        to: AnyAttribute
    ) {
        self.from = AttributeRef(from)
        self.to = AttributeRef(to)
    }
}

extension Edge: CustomStringConvertible {
    var description: String {
        let fromId: String = from.ref.id.uuidString.replacingOccurrences(of: "-", with: "")
        let toId: String = to.ref.id.uuidString.replacingOccurrences(of: "-", with: "")
        return "\"\(fromId)\" -> \"\(toId)\"\(state == .dirty ? " [style=dashed]" : "")"
    }
}

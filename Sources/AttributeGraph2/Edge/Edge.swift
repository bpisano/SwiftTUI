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

    init(from: AttributeRef, to: AttributeRef) {
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

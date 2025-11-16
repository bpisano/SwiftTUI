//final class AttributeGraph {
//    var nodes: [AnyNode] = []
//    var currentComputation: AnyNode?
//
//    func add<T>(
//        _ name: String,
//        _ value: T
//    ) -> Node<T> {
//        let node: Node<T> = .init(
//            attachedTo: self,
//            named: name,
//            value
//        )
//        nodes.append(node)
//        return node
//    }
//
//    func add<T>(
//        _ name: String,
//        _ value: @escaping () -> T
//    ) -> Node<T> {
//        let node: Node<T> = .init(
//            attachedTo: self,
//            named: name,
//            value()
//        )
//        nodes.append(node)
//        return node
//    }
//}
//
//extension AttributeGraph: CustomStringConvertible {
//    var description: String {
//        let nodesDescription = nodes.map { $0.description }.joined(separator: "\n    ")
//        let edgesDescription = nodes
//            .flatMap { node in
//                node.outgoingEdges.map(\.description)
//            }
//            .joined(separator: "\n    ")
//
//        return """
//        digraph {
//            \(nodesDescription)
//            \(edgesDescription)
//        }
//        """
//    }
//}
//
//protocol AnyNode: AnyObject, CustomStringConvertible {
//    var name: String { get }
//
//    var incomingEdges: [_Edge] { get set }
//    var outgoingEdges: [_Edge] { get set }
//
//    var potentiallyDirty: Bool { get set }
//
//    func addDependency(to node: AnyNode)
//    func computeValueIfNeeded()
//}
//
//extension AnyNode {
//    var description: String {
//        "\(name)\(potentiallyDirty ? " [style=dashed]" : "")"
//    }
//}
//
//final class Node<T>: @MainActor AnyNode {
//    unowned let graph: AttributeGraph
//
//    var incomingEdges: [_Edge] = []
//    var outgoingEdges: [_Edge] = []
//
//    var potentiallyDirty: Bool = false {
//        didSet {
//            guard potentiallyDirty, oldValue != potentiallyDirty else { return }
//            for edge in outgoingEdges {
//                edge.to.potentiallyDirty = true
//            }
//        }
//    }
//
//    let name: String
//    var value: T {
//        // Capture the dependency
//        if let currentComputation = graph.currentComputation {
//            addDependency(to: currentComputation)
//        }
//
//        computeValueIfNeeded()
//
//        // Avoir re-evaluation if not dirty
//        if let cachedValue, !potentiallyDirty {
//            return cachedValue
//        }
//
//        return cachedValue!
//    }
//
//    private var computeValue: () -> T
//    private var cachedValue: T?
//
//    init(
//        attachedTo graph: AttributeGraph,
//        named name: String,
//        _ computeValue: @escaping @autoclosure () -> T
//    ) {
//        self.graph = graph
//        self.name = name
//        self.computeValue = computeValue
//    }
//
//    func setValue(_ newValue: @escaping @autoclosure () -> T) {
//        computeValue = newValue
//        cachedValue = newValue()
//
//        for edge in outgoingEdges {
//            edge.isPending = true
//            edge.to.potentiallyDirty = true
//        }
//    }
//
//    func addDependency(to node: AnyNode) {
//        let edge: _Edge = .init(from: self, to: node)
//        outgoingEdges.append(edge)
//        node.incomingEdges.append(edge)
//    }
//
//    func computeValueIfNeeded() {
//        // Ensure all dependencies are up to date
//        for edge in incomingEdges {
//            edge.from.computeValueIfNeeded()
//        }
//
//        // Clear dirty flag
//        potentiallyDirty = false
//
//        // Check if any incoming edge is still pending
//        let hasPendingIncomingEdge: Bool = incomingEdges.contains { $0.isPending }
//        guard hasPendingIncomingEdge || cachedValue == nil else { return }
//
//        // Capture dependencies during computation
//        let previouslyComputing: AnyNode? = graph.currentComputation
//        defer { graph.currentComputation = previouslyComputing }
//        if cachedValue == nil {
//            graph.currentComputation = self
//        }
//
//        // Recompute value
//        let previousValue: T? = cachedValue
//        let newValue: T = computeValue()
//        cachedValue = newValue
//
//        // TODO: only if cached value has changed
//        if previousValue != nil {
//            for edge in incomingEdges {
//                edge.isPending = false
//            }
//            for edge in outgoingEdges {
//                edge.isPending = true
//            }
//        }
//    }
//}
//
//final class _Edge {
//    unowned let from: AnyNode
//    unowned let to: AnyNode
//    var isPending: Bool = false
//
//    init(from: AnyNode, to: AnyNode) {
//        self.from = from
//        self.to = to
//    }
//}
//
//extension _Edge: CustomStringConvertible {
//    var description: String {
//        "\(from.name) -> \(to.name)\(isPending ? " [style=dashed]" : "")"
//    }
//}

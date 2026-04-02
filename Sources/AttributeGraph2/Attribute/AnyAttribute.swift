import Foundation

public protocol AnyAttribute {
    var id: UUID { get }
    var label: String { get set }
    var incomingEdges: Set<Edge> { get }
    var outgoingEdges: Set<Edge> { get }
    var state: AttributeState { get set }

    func evaluateIfNeeded()

    /// Evaluates the underlying rule and returns whether the value changed.
    /// Only intended to be called from within an `evaluateIfNeeded` post-order sweep.
    func evaluateSelf() -> Bool

    func addIncoming(edge: Edge)
    func addOutgoing(edge: Edge)
    func removeIncoming(edge: Edge)
    func removeOutgoing(edge: Edge)
}

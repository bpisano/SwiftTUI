//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

public protocol AnyAttribute: DigraphRepresentable {
    var id: UUID { get }
    var flags: AttributeFlags { get }
    var label: String { get }
    var incomingEdges: Set<Edge> { get }
    var outgoingEdges: Set<Edge> { get }
    var state: AttributeState { get set }

    func evaluateIfNeeded()
    @discardableResult func evaluateSelf() -> Bool

    func addIncoming(edge: Edge)
    func addOutgoing(edge: Edge)
    func removeIncoming(edge: Edge)
    func removeOutgoing(edge: Edge)

    func detachRef()
}

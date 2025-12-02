//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation

protocol AnyAttribute: CustomStringConvertible {
    var id: UUID { get }
    var label: String { get }
    var incomingEdges: [Edge] { get }
    var outgoingEdges: [Edge] { get }

    func evaluateIfNeeded()
    func addIncoming(edge: Edge)
    func addOutgoing(edge: Edge)
    func makePotentiallyDirty()
}

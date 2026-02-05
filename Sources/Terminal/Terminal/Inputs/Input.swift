//
//  Input.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation

public protocol Input: Sendable {
    associatedtype Event: Sendable

    @InputActor
    func events() -> AsyncStream<Event>
}

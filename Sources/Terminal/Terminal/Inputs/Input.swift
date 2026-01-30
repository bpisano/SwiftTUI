//
//  Input.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 29/01/2026.
//

import Foundation

@InputActor
public protocol Input {
    associatedtype Event

    func events() -> AsyncStream<Event>
}

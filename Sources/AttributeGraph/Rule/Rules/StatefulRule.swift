//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/01/2026.
//

import Foundation

public protocol StatefulRule: Rule {
    func update() -> Value
}

public extension StatefulRule {
    func evaluate() -> Value {
        update()
    }
}

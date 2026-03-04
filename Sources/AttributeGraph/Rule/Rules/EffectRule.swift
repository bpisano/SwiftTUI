//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 04/03/2026.
//

import Foundation

public protocol EffectRule: Rule where Value == Void {
    func update()
}

public extension EffectRule {
    func evaluate() {
        update()
    }
}

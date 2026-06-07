//
//  DynamicProperty.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation
import AttributeGraph

public protocol DynamicProperty {
    func update()
}

public extension DynamicProperty {
    func update() {}
}

extension DynamicProperty {
    func reconnect(using cache: DynamicPropertyCache, at index: Int) {
        update()
    }
}

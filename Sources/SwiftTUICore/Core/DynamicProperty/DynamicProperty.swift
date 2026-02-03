//
//  File.swift
//  AttributeGraph
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

extension Attribute where T: View {
    func updateDynamicProperties() {
        let mirror = Mirror(reflecting: unsafeValue)
        for child in mirror.children {
            if let dynamicProperty = child.value as? DynamicProperty {
                dynamicProperty.update()
            }
        }
    }
}

extension Attribute where T: ViewModifier {
    func updateDynamicProperties() {
        let mirror = Mirror(reflecting: unsafeValue)
        for child in mirror.children {
            if let dynamicProperty = child.value as? DynamicProperty {
                dynamicProperty.update()
            }
        }
    }
}

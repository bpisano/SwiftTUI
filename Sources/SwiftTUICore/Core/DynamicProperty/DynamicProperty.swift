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
    func updateDynamicProperties(environment: Attribute<EnvironmentValues>) {
        let mirror = Mirror(reflecting: unsafeValue)
        for child in mirror.children {
            if let dynamicProperty = child.value as? DynamicProperty {
                dynamicProperty.update()
            } else if let environmentProperty = child.value as? EnvironmentProperty {
                environmentProperty.update(environment: environment)
            }
        }
    }
}

extension Attribute where T: ViewModifier {
    func updateDynamicProperties(environment: Attribute<EnvironmentValues>) {
        let mirror = Mirror(reflecting: unsafeValue)
        for child in mirror.children {
            if let dynamicProperty = child.value as? DynamicProperty {
                dynamicProperty.update()
            } else if let environmentProperty = child.value as? EnvironmentProperty {
                environmentProperty.update(environment: environment)
            }
        }
    }
}

//
//  File.swift
//  AttributeGraph
//
//  Created by Benjamin Pisano on 30/10/2025.
//

import Foundation
import AttributeGraph

@propertyWrapper
public struct State<Value> {
    let attribute: Attribute<Value>

    public var wrappedValue: Value {
        get {
            attribute.wrappedValue
        }
        nonmutating set {
            attribute.wrappedValue = newValue
        }
    }

    public var projectedValue: Binding<Value> {
        Binding(
            get: {
                self.attribute.wrappedValue
            },
            set: { newValue in
                self.attribute.wrappedValue = newValue
            }
        )
    }

    public init(wrappedValue: Value) {
        self.attribute = Attribute(wrappedValue: wrappedValue)
    }
}

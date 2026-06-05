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

    /// Reconnects this property to its persistent storage for the owning view node.
    ///
    /// Called every time the view value is (re)evaluated. Recreated view structs
    /// (for example, the children produced by ``ForEach``) get fresh property
    /// wrapper instances; this gives each one a chance to adopt the storage that
    /// was created the first time the view node was set up, instead of resetting.
    func reconnect(using cache: DynamicPropertyCache, at index: Int)
}

public extension DynamicProperty {
    func update() {}

    func reconnect(using cache: DynamicPropertyCache, at index: Int) {
        update()
    }
}

/// Persistent storage for a view node's dynamic properties.
///
/// One cache is created per view node when its body attribute is built, and it
/// outlives the individual view structs that flow through that node. Property
/// wrappers (such as ``State``) stash their storage here, keyed by declaration
/// order, so the value survives re-renders even when the struct is recreated.
@MainActor
public final class DynamicPropertyCache {
    private var storages: [Int: Any] = [:]

    public init() {}

    public subscript(index: Int) -> Any? {
        get { storages[index] }
        set { storages[index] = newValue }
    }
}

extension Attribute where T: View {
    func updateDynamicProperties(
        cache: DynamicPropertyCache,
        environment: Attribute<EnvironmentValues>
    ) {
        let mirror = Mirror(reflecting: wrappedValue)
        var index: Int = 0
        for child in mirror.children {
            if let dynamicProperty = child.value as? DynamicProperty {
                dynamicProperty.reconnect(using: cache, at: index)
                index += 1
            } else if let environmentProperty = child.value as? EnvironmentProperty {
                environmentProperty.update(environment: environment)
            }
        }
    }
}

extension Attribute where T: ViewModifier {
    func updateDynamicProperties(
        cache: DynamicPropertyCache,
        environment: Attribute<EnvironmentValues>
    ) {
        let mirror = Mirror(reflecting: wrappedValue)
        var index: Int = 0
        for child in mirror.children {
            if let dynamicProperty = child.value as? DynamicProperty {
                dynamicProperty.reconnect(using: cache, at: index)
                index += 1
            } else if let environmentProperty = child.value as? EnvironmentProperty {
                environmentProperty.update(environment: environment)
            }
        }
    }
}

//
//  DynamicPropertyCache.swift
//  SwiftTUICore
//
//  Created by Benjamin Pisano on 03/02/2026.
//

import Foundation
import AttributeGraph

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

    /// Reconnects a value's dynamic properties (`@State`, `@Environment`, …) to this storage
    /// and the current environment.
    ///
    /// The value must be the *same instance* that is then read for its `body`: because property
    /// wrappers such as ``State`` are reference-backed, reconnecting one copy and reading another
    /// would leave `body` looking at out-of-sync storage. Callers therefore read the view/modifier
    /// value once and pass it here, then read `body` from that same value.
    func reconnectProperties(
        of value: some Any,
        environment: Attribute<EnvironmentValues>
    ) {
        let mirror: Mirror = .init(reflecting: value)
        var index: Int = 0
        for child in mirror.children {
            if let dynamicProperty = child.value as? DynamicProperty {
                dynamicProperty.reconnect(using: self, at: index)
                index += 1
            } else if let environmentProperty = child.value as? EnvironmentProperty {
                environmentProperty.update(environment: environment)
            }
        }
    }
}

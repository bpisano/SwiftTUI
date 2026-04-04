//
//  LayoutEngine.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 03/04/2026.
//

import Foundation
import AttributeGraph
import Geometry

/// Stateful wrapper around a `Layout` that owns the cache for its lifetime.
///
/// Mirrors OpenSwiftUI's `ViewLayoutEngine<L>` stored inside `StaticLayoutComputer`.
/// The engine is created once per layout node and reused across re-evaluations.
/// `makeCache` is called **exactly once** at init; `updateCache` is called on
/// subsequent updates.
///
/// Child subviews are stored as **lazy providers** (`() -> LayoutComputer`), matching
/// OpenSwiftUI's `LayoutProxyAttributes` model where child `layoutComputer` attributes
/// are stored by reference and resolved only when `sizeThatFits`/`placeSubviews` runs.
/// This prevents eager recursion through the entire view tree when the parent's
/// `layoutComputer` attribute is first evaluated.
final class LayoutEngine<L: Layout> {
    private var layout: L
    private var cache: L.Cache
    private var proxies: [LayoutProxy] = []
    private var geometryStore = GeometryStore()

    /// Attribute-backed init used by `LayoutView.makeView`.
    ///
    /// Child layout computers are resolved lazily via `attribute.wrappedValue`
    /// when layout actually runs, so evaluating the parent attribute does not
    /// recursively evaluate the entire subtree.
    init(layout: L, subviewAttributes: [Attribute<LayoutComputer>]) {
        self.layout = layout
        let (proxies, store) = Self.buildSubviews(subviewAttributes.map { attr in { attr.wrappedValue } })
        self.proxies = proxies
        self.geometryStore = store
        self.cache = layout.makeCache(subviews: proxies)
    }

    /// Direct-value init used by the existential `layoutComputer(for:)` path.
    ///
    /// Values are already resolved at the call site, so no recursion risk.
    init(layout: L, subviews: [LayoutComputer]) {
        self.layout = layout
        let (proxies, store) = Self.buildSubviews(subviews.map { comp in { comp } })
        self.proxies = proxies
        self.geometryStore = store
        self.cache = layout.makeCache(subviews: proxies)
    }

    /// Called on every re-evaluation of the `layoutComputer` attribute node.
    func update(layout: L, subviewAttributes: [Attribute<LayoutComputer>]) {
        self.layout = layout
        let (proxies, store) = Self.buildSubviews(subviewAttributes.map { attr in { attr.wrappedValue } })
        self.proxies = proxies
        self.geometryStore = store
        layout.updateCache(&cache, subviews: proxies)
    }

    /// Direct-value update used by the existential path and performance tests.
    func update(layout: L, subviews: [LayoutComputer]) {
        self.layout = layout
        let (proxies, store) = Self.buildSubviews(subviews.map { comp in { comp } })
        self.proxies = proxies
        self.geometryStore = store
        layout.updateCache(&cache, subviews: proxies)
    }

    /// Returns a `LayoutComputer` whose closures share `cache` across the
    /// `sizeThatFits` → `placeSubviews` sequence within the same render pass.
    func makeLayoutComputer() -> LayoutComputer {
        LayoutComputer { [self] proposal in
            layout.sizeThatFits(proposal: proposal, subviews: proxies, cache: &cache)
        } viewGeometries: { [self] rect in
            layout.placeSubviews(in: rect, subviews: proxies, cache: &cache)
            return geometryStore.items
        }
    }

    // MARK: - Private

    /// Builds proxies from lazy providers without requiring `self` to exist yet.
    ///
    /// Each proxy captures a `GeometryStore` — a reference type — so that
    /// `place(in:)` can safely write geometry results without a `[weak self]`
    /// back-reference. This lets `makeCache` be called **once** with the real
    /// proxy array rather than needing a placeholder empty-array call first.
    private static func buildSubviews(
        _ providers: [() -> LayoutComputer]
    ) -> ([LayoutProxy], GeometryStore) {
        let store = GeometryStore(count: providers.count)
        let proxies = providers.enumerated().map { index, provider in
            LayoutProxy(computerProvider: provider) { rect in
                store.items[index] = rect
            }
        }
        return (proxies, store)
    }
}

// MARK: - GeometryStore

/// Reference-type container for per-child geometry results.
///
/// Captured by proxy `place` closures so that writes survive after `buildSubviews`
/// returns — without requiring a `[weak self]` back-reference to `LayoutEngine`.
private final class GeometryStore {
    var items: [ViewGeometry]

    init(count: Int = 0) {
        items = Array(repeating: .zero, count: count)
    }
}

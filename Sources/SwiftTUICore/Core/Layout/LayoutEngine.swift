//
//  LayoutEngine.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 03/04/2026.
//

import Foundation
import Geometry

/// Stateful wrapper around a `Layout` that owns the cache for its lifetime.
///
/// `LayoutEngine` is created once per layout node in the attribute graph and
/// reused across re-evaluations. `makeCache` is called once on init;
/// `updateCache` is called on every subsequent re-evaluation, so the cache
/// survives graph invalidations without being discarded.
final class LayoutEngine<L: Layout> {
    private var layout: L
    private var cache: L.Cache
    private var proxies: [LayoutProxy] = []
    private var geometries: [ViewGeometry] = []

    init(layout: L, subviews: [LayoutComputer]) {
        self.layout = layout
        // Initialise cache with a placeholder so all stored properties are set
        // before calling instance methods (Swift two-phase init requirement).
        self.cache = layout.makeCache(subviews: [])
        setSubviews(subviews)
        // Real makeCache now that proxies are built.
        self.cache = layout.makeCache(subviews: proxies)
    }

    /// Called on every re-evaluation of the `layoutComputer` attribute node.
    /// Updates internal state without reallocating the cache from scratch.
    func update(layout: L, subviews: [LayoutComputer]) {
        self.layout = layout
        setSubviews(subviews)
        layout.updateCache(&cache, subviews: proxies)
    }

    /// Returns a `LayoutComputer` whose closures share `cache` across the
    /// `sizeThatFits` → `placeSubviews` sequence within the same render pass.
    func makeLayoutComputer() -> LayoutComputer {
        LayoutComputer { [self] proposal in
            layout.sizeThatFits(proposal: proposal, subviews: proxies, cache: &cache)
        } viewGeometries: { [self] rect in
            // Uncomment the next line to disable within-pass cache sharing
            // (forces `placeSubviews` to recalculate instead of reading from cache):
            // var freshCache = layout.makeCache(subviews: proxies)
            layout.placeSubviews(in: rect, subviews: proxies, cache: &cache)
            return geometries
        }
    }

    // MARK: - Private

    private func setSubviews(_ subviews: [LayoutComputer]) {
        geometries = Array(repeating: .zero, count: subviews.count)
        proxies = subviews.enumerated().map { index, computer in
            LayoutProxy(layoutComputer: computer) { [weak self] rect in
                self?.geometries[index] = rect
            }
        }
    }
}

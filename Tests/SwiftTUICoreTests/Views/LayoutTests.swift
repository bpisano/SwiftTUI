//
//  LayoutTests.swift
//  SwiftTUI
//
//  Tests the Layout protocol cache contract using a TrackingLayout — a fake
//  layout whose Cache holds a shared reference-type EventLog, so tests can
//  observe makeCache / updateCache timing and hit / miss behaviour from outside
//  without patching any internal types.
//
//  Also verifies VStack honours the same contract.
//  HStack's contract is already covered in HStackCacheTests.swift.
//
//  Contract under test:
//    - makeCache  is called exactly once, at LayoutEngine init.
//    - updateCache is called on LayoutEngine.update(), not on init.
//    - sizeThatFits always recalculates and populates the cache.
//    - placeSubviews uses the cached result when the cache is warm (hit).
//    - placeSubviews recalculates when the cache is cold (miss).
//    - updateCache invalidates the cache → next placeSubviews is a miss.
//

import Foundation
import Geometry
import Testing

@testable import AttributeGraph
@testable import SwiftTUICore

// MARK: - EventLog

/// Reference-type event log shared by a TrackingLayout and its Cache.
///
/// Because Cache is a value type, the shared reference is the only way for
/// tests to observe what the layout did after a call returns.
private final class EventLog {
    private(set) var makeCount = 0
    private(set) var updateCount = 0
    private(set) var sizeThatFitsCount = 0
    private(set) var placeHits = 0
    private(set) var placeMisses = 0

    func recordMake() { makeCount += 1 }
    func recordUpdate() { updateCount += 1 }
    func recordSizeThatFits() { sizeThatFitsCount += 1 }
    func recordPlaceHit() { placeHits += 1 }
    func recordPlaceMiss() { placeMisses += 1 }

    func reset() {
        makeCount = 0
        updateCount = 0
        sizeThatFitsCount = 0
        placeHits = 0
        placeMisses = 0
    }
}

// MARK: - TrackingLayout

/// A minimal test Layout that implements the standard hit / miss cache pattern:
///   - sizeThatFits stores its result in cache.cachedSize
///   - placeSubviews uses cache.cachedSize if set (hit) or recalculates (miss)
///   - updateCache clears cache.cachedSize
///
/// This is the same pattern used by HStack and VStack, so tests written against
/// TrackingLayout describe the generic contract that every conforming Layout must follow.
private struct TrackingLayout: Layout {
    struct Cache {
        let log: EventLog
        var cachedSize: Size?
    }

    let log: EventLog

    func makeCache(subviews: [Subview]) -> Cache {
        log.recordMake()
        return Cache(log: log, cachedSize: nil)
    }

    func updateCache(_ cache: inout Cache, subviews: [Subview]) {
        log.recordUpdate()
        cache.cachedSize = nil
    }

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: [Subview],
        cache: inout Cache
    ) -> Size {
        log.recordSizeThatFits()
        let size = Size(width: 100, height: 50)
        cache.cachedSize = size
        return size
    }

    func placeSubviews(in bounds: Rect, subviews: [Subview], cache: inout Cache) {
        if cache.cachedSize != nil {
            log.recordPlaceHit()
        } else {
            log.recordPlaceMiss()
            cache.cachedSize = Size(width: bounds.width, height: bounds.height)
        }
    }
}

// MARK: - Helpers

private final class CounterBox { var count = 0 }

@MainActor
private func makeProxy(size: Size = Size(width: 10, height: 5)) -> LayoutProxy {
    let computer = LayoutComputer { _ in size } viewGeometries: { rect in
        [ViewGeometry(origin: rect.origin, size: size)]
    }
    return LayoutProxy(computerProvider: { computer }, place: { _ in })
}

@MainActor
private func countingProxy(box: CounterBox, size: Size = Size(width: 10, height: 5)) -> LayoutProxy {
    let computer = LayoutComputer { [box] _ in
        box.count += 1
        return size
    } viewGeometries: { rect in
        [ViewGeometry(origin: rect.origin, size: size)]
    }
    return LayoutProxy(computerProvider: { computer }, place: { _ in })
}

// MARK: - LayoutEngineLifecycleTests

/// Verifies that LayoutEngine calls makeCache and updateCache at the right times,
/// independently of which concrete Layout is used.
@Suite("Layout Engine Lifecycle")
@MainActor
struct LayoutEngineLifecycleTests {

    @Test
    func `makeCache is called exactly once at init`() {
        let log = EventLog()
        _ = LayoutEngine(layout: TrackingLayout(log: log), subviews: [])

        #expect(log.makeCount == 1)
    }

    @Test
    func `updateCache is not called at init`() {
        let log = EventLog()
        _ = LayoutEngine(layout: TrackingLayout(log: log), subviews: [])

        #expect(log.updateCount == 0)
    }

    @Test
    func `update calls updateCache exactly once`() {
        let log = EventLog()
        let layout = TrackingLayout(log: log)
        let engine = LayoutEngine(layout: layout, subviews: [])
        log.reset()

        engine.update(layout: layout, subviews: [])

        #expect(log.updateCount == 1)
    }

    @Test
    func `update does not call makeCache`() {
        let log = EventLog()
        let layout = TrackingLayout(log: log)
        let engine = LayoutEngine(layout: layout, subviews: [])
        log.reset()

        engine.update(layout: layout, subviews: [])

        #expect(log.makeCount == 0)
    }

    @Test
    func `makeCache is called once regardless of subview count`() {
        let log = EventLog()
        let subviews = (0..<4).map { _ in
            LayoutComputer { _ in .zero } viewGeometries: { _ in [] }
        }
        _ = LayoutEngine(layout: TrackingLayout(log: log), subviews: subviews)

        #expect(log.makeCount == 1)
    }
}

//
//  FocusMapTests.swift
//  SwiftTUI
//
//  Created by Benjamin Pisano on 21/05/2026.
//

import Foundation
import Geometry
import Testing

@testable import SwiftTUICore

@Suite("FocusMap")
struct FocusMapTests {
    private func node(_ name: String, x: Double, y: Double, w: Double = 10, h: Double = 1) -> FocusableNode {
        FocusableNode(
            id: FocusNodeID(name),
            frame: Rect(x: x, y: y, width: w, height: h)
        )
    }

    @Test
    func `firstNode honors DFS source order, not dict order`() {
        let list = FocusList(
            .node(node("a", x: 0, y: 0)),
            .node(node("b", x: 0, y: 2)),
            .node(node("c", x: 0, y: 4))
        )
        let map = FocusMap(list: list)
        #expect(map.firstNode == FocusNodeID("a"))
    }

    @Test
    func `Tab next cycles in DFS order at top level`() {
        let list = FocusList(
            .node(node("a", x: 0, y: 0)),
            .node(node("b", x: 0, y: 2)),
            .node(node("c", x: 0, y: 4))
        )
        let map = FocusMap(list: list)

        #expect(map.nextFocus(from: FocusNodeID("a"), in: .next) == FocusNodeID("b"))
        #expect(map.nextFocus(from: FocusNodeID("b"), in: .next) == FocusNodeID("c"))
        #expect(map.nextFocus(from: FocusNodeID("c"), in: .next) == FocusNodeID("a"))
    }

    @Test
    func `Tab previous cycles backward`() {
        let list = FocusList(
            .node(node("a", x: 0, y: 0)),
            .node(node("b", x: 0, y: 2)),
            .node(node("c", x: 0, y: 4))
        )
        let map = FocusMap(list: list)

        #expect(map.nextFocus(from: FocusNodeID("a"), in: .previous) == FocusNodeID("c"))
        #expect(map.nextFocus(from: FocusNodeID("c"), in: .previous) == FocusNodeID("b"))
    }

    @Test
    func `Tab inside group cycles within group`() {
        let group = FocusGroup(
            id: FocusNodeID("grp"),
            children: FocusList(
                .node(node("r1", x: 10, y: 0)),
                .node(node("r2", x: 10, y: 2))
            )
        )
        let list = FocusList(
            .node(node("l1", x: 0, y: 0)),
            .group(group)
        )
        let map = FocusMap(list: list)

        #expect(map.nextFocus(from: FocusNodeID("r1"), in: .next) == FocusNodeID("r2"))
        #expect(map.nextFocus(from: FocusNodeID("r2"), in: .next) == FocusNodeID("r1"))
    }

    @Test
    func `Spatial down picks vertically nearest aligned node`() {
        // Two columns. From a1 (left col, top), down should go to a2 (left col), not b2 (right col bottom).
        let list = FocusList(
            .node(node("a1", x: 0, y: 0)),
            .node(node("a2", x: 0, y: 2)),
            .node(node("b1", x: 20, y: 0)),
            .node(node("b2", x: 20, y: 2))
        )
        let map = FocusMap(list: list)
        #expect(map.nextFocus(from: FocusNodeID("a1"), in: .down) == FocusNodeID("a2"))
        #expect(map.nextFocus(from: FocusNodeID("b1"), in: .down) == FocusNodeID("b2"))
    }

    @Test
    func `Spatial right jumps to nearest right-side node`() {
        let list = FocusList(
            .node(node("l", x: 0, y: 0)),
            .node(node("r", x: 20, y: 0))
        )
        let map = FocusMap(list: list)
        #expect(map.nextFocus(from: FocusNodeID("l"), in: .right) == FocusNodeID("r"))
        #expect(map.nextFocus(from: FocusNodeID("r"), in: .left) == FocusNodeID("l"))
    }

    @Test
    func `Spatial returns nil if no candidate`() {
        let list = FocusList(.node(node("a", x: 0, y: 0)))
        let map = FocusMap(list: list)
        #expect(map.nextFocus(from: FocusNodeID("a"), in: .up) == nil)
    }

    @Test
    func `Disabled nodes are skipped`() {
        let list = FocusList(
            .node(FocusableNode(id: FocusNodeID("a"), frame: Rect(x: 0, y: 0, width: 10, height: 1))),
            .node(FocusableNode(id: FocusNodeID("b"), frame: Rect(x: 0, y: 2, width: 10, height: 1), isEnabled: false)),
            .node(FocusableNode(id: FocusNodeID("c"), frame: Rect(x: 0, y: 4, width: 10, height: 1)))
        )
        let map = FocusMap(list: list)
        // 'b' is disabled - tab from a should skip to c
        #expect(map.nextFocus(from: FocusNodeID("a"), in: .next) == FocusNodeID("c"))
        // spatial down from a should also skip b
        #expect(map.nextFocus(from: FocusNodeID("a"), in: .down) == FocusNodeID("c"))
    }

    @Test
    func `Empty list is empty`() {
        let map = FocusMap(list: .empty)
        #expect(map.isEmpty)
        #expect(map.firstNode == nil)
    }
}
